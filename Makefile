VERSION=10.6

docker:
	docker build -t mobilejazz/mariadb-backup-s3:${VERSION} .

push:
	docker push mobilejazz/mariadb-backup-s3:${VERSION}
