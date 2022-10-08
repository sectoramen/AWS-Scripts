import argparse
import logging
import boto3
import sys
from botocore.exceptions import ClientError
import requests
from datetime import datetime, timezone

logger = logging.getLogger(__name__)

def generate_presigned_url(s3_client, client_method, method_parameters, expires_in):
    """
    Generate a presigned Amazon S3 URL that can be used to perform an action.

    :param s3_client: A Boto3 Amazon S3 client.
    :param client_method: The name of the client method that the URL performs.
    :param method_parameters: The parameters of the specified client method.
    :param expires_in: The number of seconds the presigned URL is valid for.
    :return: The presigned URL.
    """
    try:
        url = s3_client.generate_presigned_url(
            ClientMethod=client_method,
            Params=method_parameters,
            ExpiresIn=expires_in
        )
        logger.info("Got presigned URL: %s", url)
    except ClientError:
        logger.exception(
            "Couldn't get a presigned URL for client method '%s'.", client_method)
        raise
    return url

def test_object(bucket,key):
    s3 = boto3.resource('s3')
    try:
        s3.Object(bucket, key).load()
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            return False
            # The object does not exist.
        else:
            return False
            # Something else has gone wrong.
            raise
    else:
        return True
    # The object does exist.       

def usage_demo():

    print('-'*88)
    parser = argparse.ArgumentParser()
    parser.add_argument('bucket', help="The name of the bucket.")
    parser.add_argument(
        'key', help="For a GET operation, the key of the object in Amazon S3. For a "
                    "PUT operation, the name of a file to upload.")
    parser.add_argument(
        'action', choices=('get', 'put'), help="The action to perform.")
    parser.add_argument(
        'expiration', help="Time in seconds for the presigned URL to remain valid.")    
    args = parser.parse_args()

    if boto3.session.Session().get_credentials() is None:
        print('Please provide Boto3 credentials, e.g. via the AWS_ACCESS_KEY_ID '
            'and AWS_SECRET_ACCESS_KEY environment variables.')
        sys.exit(-1)   

    s3_client = boto3.client('s3')
    client_action = 'get_object' if args.action == 'get' else 'put_object'
    url = generate_presigned_url(
        s3_client, client_action, {'Bucket': args.bucket, 'Key': args.key}, args.expiration)

    # Test if the object already exists
    object = test_object(args.bucket, args.key)

    # Test the presigned URL
 
    if client_action == 'get_object':
        status = requests.get(url)
    elif (client_action == 'put_object') and (not object):
        status = requests.put(url)
    else:
        print('A file named', args.key, 'already exists in', args.bucket)
        print('You must specify a file name that does not exist in the bucket')
        exit(1)
    if status.status_code == 400: 
        print('HTTP Error', status.status_code, 'your credentials do not allow for', client_action, 'on bucket', args.bucket)
    elif status.status_code == 404:
        print('HTTP Error', status.status_code, 'a', client_action, 'action was attempted on a non existing', args.key, 'file on bucket', args.bucket)    
    elif status.status_code != 200: 
        print('HTTP Error', status.status_code, 'error', client_action, 'on bucket', args.bucket)
    else:
        print('** An empty file named', args.key, 'has been placed in', args.bucket, 'as a placeholder for the incoming file.')
        print('** Use or provide the presigned URL below to upload the actual file.')       
        timestamp = url.split("Expires=")
        dt = datetime.fromtimestamp(int(timestamp[1]))
        print(url)
        print('** This URL will expire on', dt)
    print('-'*88)

if __name__ == '__main__':
    usage_demo()

