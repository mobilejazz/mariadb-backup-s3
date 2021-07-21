docker:
	docker build -t mobilejazz/mariadb-backup-s3 .

push:
	docker push mobilejazz/mariadb-backup-s3
