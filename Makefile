VERSION=mysqldump-8.0

all: docker push

docker:
	docker build -t mobilejazz/mysql-backup-s3:${VERSION} .

push:
	docker push mobilejazz/mysql-backup-s3:${VERSION}

