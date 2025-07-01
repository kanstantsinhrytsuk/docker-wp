FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by WordPress
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        zip \
        intl \
        mbstring \
        xml \
        soap \
        bcmath \
        exif \
        opcache

# Set proper permissions
RUN chown -R www-data:www-data /var/www

# Create WordPress directories if they don't exist
RUN mkdir -p /var/www/website/v1 /var/www/website/v2

WORKDIR /var/www/website

EXPOSE 9000

CMD ["php-fpm"]
