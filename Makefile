VERSION=10.2

all: docker push

docker:
	docker build --progress=plain -t mobilejazz/mariadb-backup-s3 .
	docker tag mobilejazz/mariadb-backup-s3 mobilejazz/mariadb-backup-s3:${VERSION}

push:
	docker push mobilejazz/mariadb-backup-s3:${VERSION}
	docker push mobilejazz/mariadb-backup-s3
