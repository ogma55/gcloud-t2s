#!/bin/bash

# Execute in gcloud console !

# Check if the user provided a string as the first argument
if [ $# -lt 2 ]; then
    echo "Usage: $0 <text file> <gcloud_project_name>"
    echo "output mp3 file <text file>.mp3"
    exit 1
fi

# Get the input string from the first argument
input_string="$1"
gcloud_project_name="$2"

# Split the string into tokens of 200 characters
i=10000
while read token; do
    echo "Token: $token"
    cp request.json send.json
    sed  "s/token/$token/" send.json > send2.json

    curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "x-goog-user-project: ${gcloud_project_name}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @send2.json \
    "https://texttospeech.googleapis.com/v1/text:synthesize" > answer.json
    sed -n 's/\(.*"audioContent": "\)\(.*\)"/\2/p' answer.json > answer.base
    base64 -d -i answer.base > answer-$i.mp3
    ((i++))
done <$1

cat answer*.mp3 > $1.mp3
rm -f answer*.mp3
