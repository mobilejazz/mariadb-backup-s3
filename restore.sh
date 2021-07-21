#!/bin/bash
if [ -z "$S3_BUCKET_NAME" ]; then
    echo S3_BUCKET_NAME not defined >&2
    exit 1
fi
if [ -z "$S3_ENDPOINT" ]; then
    echo S3_BUCKET_NAME not defined >&2
    exit 1
fi
FILENAME="$1"
if [ -z "$FILENAME" ]; then
    echo Usage $0 file_to_restore >&2
    exit 1
fi

gof3r get -b "${S3_BUCKET_NAME}" --endpoint "${S3_ENDPOINT}" -k "${FILENAME}" | lbzip2 -d | mbstream -x --directory=/var/lib/mysql
mariabackup --prepare --target-dir=/var/lib/mysql/
