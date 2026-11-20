FROM debian:12

RUN apt-get update && \
    apt-get install -y php8.2 php8.2-fpm php8.2-mysql wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -q -O /var/www/html/index.php \
    https://www.adminer.org/latest.php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 9001

ENTRYPOINT [ "/entrypoint.sh" ]
