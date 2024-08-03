# Using an official MySQL image
FROM mysql:5.7
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=testdb
COPY init-db.sql /docker-entrypoint-initdb.d/
