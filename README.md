# mariadb-backup-s3

This image does backups of a MariaDB server using Mariabackup to an S3 bucket (or compatible, like Digital Ocean Spaces). Backups are streamed so there is no need for temporary disk space to hold a copy of the database. Optionally, you can set up a S3 bucket lifecycle policy to delete files after a certain amount of days.

Limitations/design decisions are favoring simplicity:
 
 * All backups are full, incremental backups are not supported
 * Backups are not "prepared"; they will be prepared when restoring (more efficient backup, slower restore)
 * It does not encrypt the backup files; transmission to the S3 bucket is protected by SSL/TLS and storage might or might not be protected, depending on your S3 bucket configuration

## How does it work?
It backs up the database with Mariabackup and streams it to a single lbzip2 compressed file (bzip2 compatible, multi-core port) with xbstream and uploads it to S3 with s3gof3r.

The backup is a single file with a timestamp name like `20191201-235701.xb`.

When first run, if `RETENTION_DAYS` is set, a lifecycle policy will be created and applied.

## Usage

Mount the MYSQL data directory on `/var/lib/mysql`.

Define the following environment variables:

 * `MYSQL_USER`
 * `MYSQL_PASSWORD`
 * `MYSQL_HOST`
 * `S3_BUCKET_NAME`
 * `S3_ENDPOINT` (eg. `s3.eu-west-1.amazonaws.com` or `fra1.digitaloceanspaces.com`)
 * `AWS_ACCESS_KEY_ID`
 * `AWS_SECRET_ACCESS_KEY`
 * `AWS_REGION` (eg. `eu-west-1` or `fra1`)
 * `WAIT_SECONDS` (number of seconds to wait between backups, if not set backup is run once)
 * `RETENTION_DAYS` (number of days copies are retained, defaults to not set, which means no retention policy is set on the bucket)

## Restore

Stop mysql and run `/restore.sh name_of_object_to_restore.xb.bz2` inside the container. Then start mysql.
