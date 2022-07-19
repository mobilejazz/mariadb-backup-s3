#!/bin/bash
if [ ! -z "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi
if [ ! -z "$AWS_SECRET_ACCESS_KEY_FILE" ]; then
    AWS_SECRET_ACCESS_KEY="$(cat "$AWS_SECRET_ACCESS_KEY_FILE")"
fi

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
xtrabackup --prepare --target-dir=/var/lib/mysql/
