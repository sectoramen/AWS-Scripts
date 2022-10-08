# My AWS Scripts

Automation makes life easier. Enjoy my cloudformation stacks!

## AssumeRole

Use: ./AssumeRole.sh AWS_Account_Num Role_ToAssume

With proper access in place, this script provides you with the bash role credentials to perform authorized actions on the target account.

## GeneratePresignedURL

Generates a presigned Amazon S3 URL that can be used to perform an action.

  :param s3_client: A Boto3 Amazon S3 client.
  :param client_method: The name of the client method that the URL performs.
  :param method_parameters: The parameters of the specified client method.
  :param expires_in: The number of seconds the presigned URL is valid for.
  :return: The presigned URL.

Usage: GeneratePresignedURL.py [-h] bucket key {get,put} expiration

## GetSecurityHubFindings

Export AWS SecurityHub findings into a tab delimited file that can be imported into Excel.
