FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install nginx -y\
    && apt install vim -y && apt install curl -y

RUN mkdir -p /etc/nginx/ssl 

RUN apt install openssl -y

RUN openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt\
    -keyout /etc/nginx/ssl/inception.key\
    -subj "/C=BE/ST=Bruxelles/L=Bruxelles/O=19/OU=Student/CN=localhost"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html 

CMD ["nginx", "-g", "daemon off;"]