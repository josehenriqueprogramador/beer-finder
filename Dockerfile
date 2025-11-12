# Base Ubuntu 24
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Pacotes essenciais
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    unzip \
    zip \
    sudo \
    libonig-dev \
    libzip-dev \
    libpq-dev \
    libxml2-dev \
    nginx \
    vim \
    bash-completion \
    && apt-get clean

# PHP 8.4
RUN add-apt-repository -y ppa:ondrej/php && apt-get update
RUN apt-get install -y \
    php8.4-cli \
    php8.4-fpm \
    php8.4-bcmath \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-curl \
    php8.4-pgsql \
    php8.4-zip \
    php8.4-opcache \
    php8.4-readline

# Config PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.4/fpm/php.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Diretório do projeto
WORKDIR /var/www/html

# Copiar código
COPY . /var/www/html

# Permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Instalar dependências do Laravel
RUN composer install

# Expor porta web
EXPOSE 80

# Rodar PHP-FPM + Nginx
CMD ["bash", "-c", "service php8.4-fpm start && nginx -g 'daemon off;'"]
