import boto3
from botocore.exceptions import ClientError

# Remove all ingress and egress rules from default security groups
client = boto3.client('ec2')
response = client.describe_security_groups(Filters=[{'Name': 'group-name', 'Values': ['default']}])
for i in response['SecurityGroups']:
    print("Working on " + i['Description'] + " with Id " + i['GroupId'] + " in VPC " + i['VpcId'] + " owned by " + i['OwnerId'])
    try:
        response = client.revoke_security_group_ingress(GroupId=i['GroupId'],  IpPermissions=i['IpPermissions'])
        print("Removed ingress rules")
    except ClientError as e:
        print(e)
    try:
        response = client.revoke_security_group_egress(GroupId=i['GroupId'],  IpPermissions=i['IpPermissionsEgress'])
        print("Removed egress rules")
    except ClientError as e:
        print(e)

# Configure strong password policy
client = boto3.client('iam')
try:
    response = client.update_account_password_policy(
        MinimumPasswordLength=14,
        RequireSymbols=True,
        RequireNumbers=True,
        RequireUppercaseCharacters=True,
        RequireLowercaseCharacters=True,
        AllowUsersToChangePassword=True,
        PasswordReusePrevention=24,
        MaxPasswordAge=90
        )
    print("Strong password policy configured")
except ClientError as e:
    print(e)

# Delete all IAM users
client = boto3.client('iam')
response = client.list_users()
for i in response['Users']:
    print("Deleting " + i['UserName'])
    try:
        response = client.delete_user(UserName=i['UserName'])
        print("Deleted " + i['UserName'])
    except ClientError as e:
        print(e)
