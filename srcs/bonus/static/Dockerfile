FROM debian:12
 
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
 
# COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/site.conf /etc/nginx/conf.d/site.conf
COPY www/index.html /var/www/static/index.html
 
RUN chown -R www-data:www-data /var/www/static
 
EXPOSE 8080
 
CMD ["nginx", "-g", "daemon off;"]
