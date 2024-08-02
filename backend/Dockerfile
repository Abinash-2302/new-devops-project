# Use an official MySQL image
FROM mysql:5.7

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=testdb

# Copy the initialization script
COPY init-db.sql /docker-entrypoint-initdb.d/
