#!/bin/bash

# This file downloads AWS SecurityHub findings in native json format
# It then parses all the primary headers (it does not handle nested headers) and creates a tab delimited file
# The file can be imported into Excel or other tools for analysis

# *** NOTE *** Your shell must have the credentials to access your AWS account security hub
if [ -z $AWS_ACCESS_KEY_ID ] || [ -z $AWS_SECRET_ACCESS_KEY ] || [ -z $AWS_SESSION_TOKEN  ]; then
    echo "The shell does not have AWS credentials."
    echo "Export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN"
    exit 1
fi

securityhubfile="securityhubfindings.json"

# Get all NEW and FAILED findings
echo "Getting NEW FAILED findings from AWS SecurityHub ..."
echo "Replace the line below if you want to download all SecurityHub findings. Example provided in the script comments"
echo -e "For ControlTower/Organizations and large accounts this could take over 1 hour with no output while gatherting\n"
aws securityhub get-findings --filters '{"WorkflowStatus": [{"Value": "NEW","Comparison":"EQUALS"}], "ComplianceStatus": [{"Value": "FAILED","Comparison":"EQUALS"}]}' > securityhubfindings.json 2>&1
mystatus=$?
if [ $mystatus -gt 0 ]; then
    echo "The AWS-CLI command \"aws securityhub get-findings\" exited with a status of $mystatus"
    echo "This could be a permission issue, SecurityHub is not enabled on the account, or some other issue"
    echo "Check https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-returncodes.html for more info"
    exit 1
fi
# Use this if you want to get all findings
# aws securityhub get-findings > $scurityhubfile
mkdir tmp
cd tmp
# Get all paths examples for troubleshooting the json file
# cat myacct.json | jq -r '.Findings[0]|paths|map(tostring)|join(".")' | sed -e 's/\.0/\[\]/g' | sed -e 's/^/\.Findings\[\]\./g'

# Print all paths' values
# for paths in $(cat myacct.json | jq -r '.Findings[0]|paths|map(tostring)|join(".")' | sed -e 's/\.0/\[\]/g' | sed -e 's/^/\.Findings\[\]\./g'); do cat myacct.json | jq $paths ; done

# Saves all path values in files with name of path -- NOTE: not all files are created due to path naming with special characters and som files have more lines if data are arrays 

echo -e "\nCreating files from JSON paths ..."
for paths in $(cat ../$securityhubfile | jq -r '.Findings[0]|paths|map(tostring)|join(".")')
do
    fullpath=$(echo $paths | sed -e 's/\.0/\[\]/g' | sed -e 's/^/\.Findings\[\]\./g' | sed -e 's/\//-/g')
    filepath=$(echo $paths | sed -e 's/\.0/\[\]/g' | sed -e 's/\//-/g' | sed -e 's/\:/-/g')
    echo "creating file for $paths"
    echo "\"$paths\"" > $filepath 2>&1
    cat ../$securityhubfile | jq $fullpath >> $filepath 2>&1

done

# This variable stores the number of findings from SchemaVersion, which is a variable that mirrors the number of findings 
# This is done so we can eliminate files with more lines due to nested json and arrays.
# We will loose some data points that will not make it to myfile.txt but this keeps the code simple. Someone with more time can improve on this
findings=$(wc -l < ./SchemaVersion| tr -d ' ')
echo -e "\nThere are $findings findings to process"

# We only use files that have as many lines as there are findings
paste=""
cp AwsAccountId ../myfile.old
echo -e "\nGenerating columns from paths ..."
for file in $(ls)                             
do
    filelines=$(wc -l < ./$file| tr -d ' ')
    if [ $filelines == $findings ] && [ $file != "AwsAccountId" ]; then
        echo "Adding $file column"
        paste ../myfile.old $file > ../myfile.txt
        cp ../myfile.txt ../myfile.old
    fi
done

# Cleanup#

echo -e "\nCleaning up and removing temp files ..."
cd ..
rm -rf tmp
rm myfile.old
echo -e "\nI generated \"myfile.txt\". This is a tab delimited file that can be imported into Excel for analysis"
echo -e "\nAll done\n"
