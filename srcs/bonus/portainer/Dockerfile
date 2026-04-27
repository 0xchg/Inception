FROM debian:12

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.21.4/portainer-2.21.4-linux-amd64.tar.gz \
    | tar -xz -C /opt/

EXPOSE 9000

CMD ["/opt/portainer/portainer", "--no-analytics"]