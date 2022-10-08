# My AWS Scripts

Automation makes life easier. Enjoy my cloudformation stacks!

## AssumeRole

Use: ./AssumeRole.sh AWS_Account_Num Role_ToAssume

With proper access in place, this script provides you with the bash role credentials to perform authorized actions on the target account.

## GeneratePresignedURL

Generates a presigned Amazon S3 URL that can be used to perform an action.

Usage: GeneratePresignedURL.py [-h] bucket key {get,put} expiration

## GetSecurityHubFindings

Export AWS SecurityHub findings into a tab delimited file that can be imported into Excel.
