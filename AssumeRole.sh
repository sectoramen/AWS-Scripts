#!/bin/bash

if [[ $# -ne 2 ]]
    then
        echo Usage: $0 AWS_Account_Num Role_ToAssume
        exit 1
fi

ACCOUNT=$1 # The AWS Account Number
ROLE=$2 # The Role to assume in a different AWS Account

ROLEARN=arn:aws:iam::$ACCOUNT:role/$ROLE
TEMP_STS_ASSUMED_FILE=$(mktemp -t sts_assumed-XXXXXX)
TEMP_STS_ASSUMED_ERROR=$(mktemp -t sts_assumed-XXXXXX)

if ! aws sts assume-role --role-arn $ROLEARN --role-session-name MYNewSessionRole > $TEMP_STS_ASSUMED_FILE 2>"${TEMP_STS_ASSUMED_ERROR}"
then
    echo "Unable to asume role"
    exit 1
fi

# Set AWS environment variables with assumed role credentials
ASSUME_AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' "${TEMP_STS_ASSUMED_FILE}")
ASSUME_AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey'  "${TEMP_STS_ASSUMED_FILE}")
ASSUME_AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken'  "${TEMP_STS_ASSUMED_FILE}")

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

rm -fr "${TEMP_STS_ASSUMED_FILE}"
rm -fr "${TEMP_STS_ASSUMED_ERROR}"
