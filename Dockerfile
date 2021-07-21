FROM ubuntu:20.04

#disabling interactive shell
ARG DEBIAN_FRONTEND=noninteractive
# mariabackup & lbzip2
RUN apt-get update && \
    apt-get install -y software-properties-common gnupg && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu focal main' && \
    apt-add-repository universe && \
    apt-get update && \
    apt-get install -y wget mariadb-backup && \
    apt install lbzip2 && \
    rm -rf /var/lib/apt/lists/*
# s3gof3r
ENV S3GOF3R_URL="https://github.com/rlmcpherson/s3gof3r/releases/download/v0.5.0/gof3r_0.5.0_linux_amd64.tar.gz"
RUN wget -O- "${S3GOF3R_URL}" | tar xvz -C /bin --strip-components=1
# s3cmd
RUN apt-get update && apt-get install -y \
	ca-certificates \
	s3cmd \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

COPY backup.sh /
COPY restore.sh /
CMD "./backup.sh"
