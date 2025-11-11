# =============================
# 📦 Dockerfile Laravel Completo (Ubuntu 24.04)
# =============================
FROM ubuntu:24.04

# -----------------------------
# Variáveis e Configurações
# -----------------------------
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
# Instala PHP e extensões
# -----------------------------
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-curl \
    php8.2-zip \
    php8.2-mysql \
    php8.2-gd \
    php8.2-intl

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
# Cria usuário e grupo (sem erro)
# -----------------------------
RUN if ! getent group ${WWWGROUP}; then groupadd -g ${WWWGROUP} ${WWWUSER}; fi && \
    if ! id -u ${WWWUSER} >/dev/null 2>&1; then useradd -ms /bin/bash -u ${WWWGROUP} -g ${WWWUSER} ${WWWUSER}; fi

# -----------------------------
# Configura Nginx
# -----------------------------
RUN rm -f /etc/nginx/sites-enabled/default
COPY ./nginx/default.conf /etc/nginx/sites-enabled/default.conf

# -----------------------------
# Configura Supervisor
# -----------------------------
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# -----------------------------
# Instala dependências Laravel
# -----------------------------
COPY . /var/www/html
RUN composer install --no-interaction --prefer-dist && \
    npm install && \
    npm run build || true && \
    chown -R ${WWWUSER}:${WWWUSER} /var/www/html

# -----------------------------
# Expõe portas e inicia serviços
# -----------------------------
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
