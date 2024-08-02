# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Set working directory
WORKDIR /var/www/html

# Copy the current directory contents into the container
COPY . /var/www/html/

# Install mysqli
RUN docker-php-ext-install mysqli

# Expose port 80
EXPOSE 80
