# 📦 Dockerfile Laravel Completo (Ubuntu 24.04)
# =============================
FROM ubuntu:24.04

ARG NODE_VERSION=22
ARG WWWGROUP=1000
ARG WWWUSER=www-data

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
WORKDIR /var/www/html

# -----------------------------
# Instala dependências básicas
# -----------------------------
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    zip \
    unzip \
    git \
    nano \
    supervisor \
    nginx \
    tzdata

# -----------------------------
# Instala PHP 8.4 e extensões
# -----------------------------
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    php8.4 \
    php8.4-cli \
    php8.4-fpm \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-bcmath \
    php8.4-curl \
    php8.4-zip \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-gd \
    php8.4-intl

# -----------------------------
# Instala Node.js
# -----------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# -----------------------------
# Instala Composer
# -----------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# -----------------------------
# Cria usuário e grupo de forma segura
# -----------------------------
RUN if ! getent group ${WWWUSER} >/dev/null; then \
        groupadd -g ${WWWGROUP} ${WWWUSER}; \
    fi && \
    if ! id -u ${WWWUSER} >/dev/null 2>&1; then \
        useradd -ms /bin/bash -g ${WWWUSER} -u ${WWWGROUP} ${WWWUSER}; \
    fi

# -----------------------------
# Remove default Nginx
# -----------------------------
RUN rm -f /etc/nginx/sites-enabled/default

# -----------------------------
# Define diretório de trabalho
# -----------------------------
WORKDIR /var/www/html

# -----------------------------
# Copia configurações e código
# -----------------------------
COPY ./nginx/default.conf /etc/nginx/sites-enabled/default.conf
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY . /var/www/html

# -----------------------------
# Instala dependências do Laravel e Node
# -----------------------------
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist && \
    npm install && \
    npm run build || true && \
    chown -R ${WWWUSER}:${WWWUSER} /var/www/html

# -----------------------------
# Expõe porta e inicia Supervisor
# -----------------------------
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
