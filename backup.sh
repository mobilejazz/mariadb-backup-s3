#!/bin/bash
if [ -z "$MYSQL_USER" ]; then
    echo MYSQL_USER not defined >&2
    exit 1
fi
if [ -z "$MYSQL_PASSWORD" ]; then
    echo MYSQL_PASSWORD not defined >&2
    exit 1
fi
if [ -z "$MYSQL_HOST" ]; then
    echo MYSQL_HOST not defined >&2
    exit 1
fi
if [ -z "$S3_BUCKET_NAME" ]; then
    echo S3_BUCKET_NAME not defined >&2
    exit 1
fi
if [ -z "$S3_ENDPOINT" ]; then
    echo S3_BUCKET_NAME not defined >&2
    exit 1
fi

# set file expiration
if [ -n "$RETENTION_DAYS" ]; then
    cat >/lifecycle.xml <<EOF
<?xml version="1.0" ?>
<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
	<Rule>
		<ID>Expire old backups</ID>
		<Prefix/>
		<Status>Enabled</Status>
		<Expiration>
			<Days>${RETENTION_DAYS}</Days>
		</Expiration>
    <AbortIncompleteMultipartUpload>
      <DaysAfterInitiation>1</DaysAfterInitiation>
    </AbortIncompleteMultipartUpload>
  </Rule>
</LifecycleConfiguration>
EOF
    if echo ${S3_ENDPOINT} | sed 's/.digitaloceanspaces.com$//'; then
        S3CMD_PARAMS="--host-bucket=%(bucket)s.${S3_ENDPOINT}"
    fi
    echo "setting bucket lifecycle policy..."
    s3cmd --access_key="${AWS_ACCESS_KEY_ID}" --secret_key="${AWS_SECRET_ACCESS_KEY}" --region="${AWS_REGION}" --host="${S3_ENDPOINT}" $S3CMD_PARAMS setlifecycle /lifecycle.xml "s3://${S3_BUCKET_NAME}"
fi

dobackup() {
    echo doing backup now...
    FILENAME="$(date '+%Y%m%d-%H%M%S').xb.bz2"
    mariabackup --backup --stream=xbstream --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host="${MYSQL_HOST}" | lbzip2 | gof3r put -b "${S3_BUCKET_NAME}" --endpoint "${S3_ENDPOINT}" -k "${FILENAME}" --no-md5
}

if [ -z "$WAIT_SECONDS" ]; then
    dobackup
else
    while true; do
        echo "waiting $WAIT_SECONDS seconds until next backup..."
        sleep "$WAIT_SECONDS"
        dobackup
    done
fi

