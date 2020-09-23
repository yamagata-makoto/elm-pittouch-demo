#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Usage: $0 URI formname upload_file"
    exit 1
fi

if [ ! -f $3 ]
then
    echo "Upload file not found"
    exit 1
fi

boundary="cloudscloudsclouds"

{
    cat <<EOF
--${boundary}
Content-Disposition: form-data; name="${2}"; filename="${3}"
Content-Type: application/octet-stream

EOF

cat $3

    cat <<EOF

--${boundary}--
EOF

} > __post__.bin

wget -O - --user=admin --password=0000 --post-file=__post__.bin $1 > /dev/null

rm -f __post__.bin
