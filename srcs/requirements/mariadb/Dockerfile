FROM debian:12

RUN apt-get update && \
    apt-get install -y mariadb-server gettext-base && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY conf/entrypoint.sh /entrypoint.sh
COPY conf/template.sql /template.sql

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT [ "/entrypoint.sh" ]
