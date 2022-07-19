FROM ubuntu:20.04

#disabling interactive shell
ARG DEBIAN_FRONTEND=noninteractive
# lbzip2
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    apt-add-repository universe && \
    apt-get install -y gnupg wget curl lbzip2 && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && \
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb && \
    rm percona-release_latest.$(lsb_release -sc)_all.deb && \
    percona-release enable-only tools && \
    apt-get update && \
    apt-get install -y percona-xtrabackup-80 && \
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
