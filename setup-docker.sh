#!/bin/bash
# Script para gerar estrutura completa Docker + Laravel + Nginx + Supervisor

# 1️⃣ Dockerfile
cat <<'DOCKER' > Dockerfile
# =============================
# 📦 Dockerfile Laravel Completo (Ubuntu 24.04)
# =============================
FROM ubuntu:24.04

ARG NODE_VERSION=22
ARG WWWGROUP=1000
ARG WWWUSER=www-data

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
WORKDIR /var/www/html

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

RUN curl -fsSL https://deb.nodesource.com/setup_\${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN if ! getent group \${WWWGROUP}; then groupadd -g \${WWWGROUP} \${WWWUSER}; fi && \
    if ! id -u \${WWWUSER} >/dev/null 2>&1; then useradd -ms /bin/bash -u \${WWWGROUP} -g \${WWWUSER} \${WWWUSER}; fi

RUN rm -f /etc/nginx/sites-enabled/default

WORKDIR /var/www/html

COPY ./nginx/default.conf /etc/nginx/sites-enabled/default.conf
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY . /var/www/html

RUN composer install --no-interaction --prefer-dist && \
    npm install && \
    npm run build || true && \
    chown -R \${WWWUSER}:\${WWWUSER} /var/www/html

EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
DOCKER

# 2️⃣ Supervisord.conf
cat <<'SUPERVISOR' > supervisord.conf
[supervisord]
nodaemon=true

[program:php-fpm]
command=/usr/sbin/php-fpm8.2 -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
SUPERVISOR

# 3️⃣ nginx/default.conf
mkdir -p nginx
cat <<'NGINX' > nginx/default.conf
server {
    listen 80;
    server_name localhost;

    root /var/www/html/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.(env|git|ht) {
        deny all;
    }

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
NGINX

# 4️⃣ .env.example
cat <<'ENVEX' > .env.example
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=secret_replace_me
MYSQL_ROOT_PASSWORD=secret_replace_me
ENVEX

# 5️⃣ .gitignore
cat <<'GITIGNORE' >> .gitignore
.env
GITIGNORE

# 6️⃣ docker-compose.yml
cat <<'COMPOSE' > docker-compose.yml
version: "3.8"
services:
  app:
    build: .
    container_name: laravel_app
    volumes:
      - .:/var/www/html
    env_file:
      - .env
    ports:
      - "8080:80"
    depends_on:
      - db

  db:
    image: mysql:8
    container_name: mysql_db
    restart: always
    env_file:
      - .env
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin:latest
    restart: always
    ports:
      - "8081:80"
    environment:
      PMA_HOST: db
      PMA_USER: ${DB_USERNAME}
      PMA_PASSWORD: ${DB_PASSWORD}

volumes:
  db_data:
COMPOSE

echo "✅ Estrutura completa criada! Agora crie seu arquivo .env a partir de .env.example e rode:"
echo "cp .env.example .env"
echo "docker-compose up --build -d"
