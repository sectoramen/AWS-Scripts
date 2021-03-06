#!/bin/bash

if [[ $# -ne 2 ]]
    then
        echo Usage: $0 AWS_Account_Num Role_To_Assume
        echo For example: $0 12345678912 MyReadOnlyRole
        exit 1
fi

ACCOUNT=$1 # The AWS Account Number, i.e. 12345678912
ROLE=$2 # The Role to assume in the AWS Account, i.e. MyReadOnlyRole

ROLEARN=arn:aws:iam::$ACCOUNT:role/$ROLE

if ! TEMP_STS_ASSUMED=$(aws sts assume-role --role-arn $ROLEARN --role-session-name MYNewSessionRole)
then
    echo "Unable to assume role"
    exit 1
fi

# Set AWS environment variables with assumed role credentials
ASSUME_AWS_ACCESS_KEY_ID=$(echo $TEMP_STS_ASSUMED | jq -r '.Credentials.AccessKeyId')
ASSUME_AWS_SECRET_ACCESS_KEY=$(echo $TEMP_STS_ASSUMED | jq -r '.Credentials.SecretAccessKey')
ASSUME_AWS_SESSION_TOKEN=$(echo $TEMP_STS_ASSUMED | jq -r '.Credentials.SessionToken')

echo
echo your current identiy is:
aws sts get-caller-identity
echo
echo export AWS_ACCESS_KEY_ID=$ASSUME_AWS_ACCESS_KEY_ID
echo export AWS_SECRET_ACCESS_KEY=$ASSUME_AWS_SECRET_ACCESS_KEY
echo export AWS_SESSION_TOKEN=$ASSUME_AWS_SESSION_TOKEN

echo
echo "Copy and Paste the above credentials on the console to assume the new role."
echo "verify your new role by running: aws sts get-caller-identity"
