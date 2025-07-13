FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/* && \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

RUN sed -i 's/bind-address.*=.*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY conf/init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

ENV MYSQL_ROOT_PASSWORD=rootpass
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=userpass
ENV MYSQL_DATABASE=mydb

CMD ["/usr/local/bin/init.sh"]

