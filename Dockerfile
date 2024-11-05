# Use a Debian-based PHP image for improved stability
FROM php:8.3.0-fpm

# Copy custom PHP-FPM configuration
ADD ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Set a working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd \
    && apt-get clean

# Install Redis extension
RUN apt-get install -y libonig-dev && \
    pecl install redis && \
    docker-php-ext-enable redis

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create a non-root user for Laravel
RUN useradd -ms /bin/bash laravel && \
    chown -R laravel:laravel /var/www/html

# Switch to non-root user
USER laravel

# Copy application code into the container
COPY --chown=laravel:laravel . /var/www/html

# Set permissions for Laravel storage and cache folders
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 and start PHP-FPM server
EXPOSE 9000
CMD ["php-fpm"]
