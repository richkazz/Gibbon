FROM ubuntu:22.04

LABEL MAINTAINER Kerron Gordon <edawarekaro@gmail.com>

ENV VERSION=27.0.01
ENV GIBBON_URL="https://github.com/GibbonEdu/core/releases/download/v${VERSION}/GibbonEduCore-InstallBundle.tar.gz"
ENV INSTALL_DIR="/var/www/gibbon.local/"

WORKDIR ${INSTALL_DIR}

# Declare the volume *after* copying files into it, otherwise the initial content
# will be overwritten by the volume mount.
# VOLUME ${INSTALL_DIR}  # Moved below

RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    php8.1 apache2 php8.1-gd php8.1-mysql php8.1-zip php8.1-curl \
    php8.1-gettext php8.1-pdo php8.1-xml php8.1-mbstring php8.1-intl wget ca-certificates && \
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/gibbon.local.conf && \
    sed -i 's+/var/www/html+${INSTALL_DIR}+g' /etc/apache2/sites-available/gibbon.local.conf && \
    ln -s ../sites-available/gibbon.local.conf /etc/apache2/sites-enabled/gibbon.local.conf && \
    a2enmod rewrite && \
    mkdir -p ${INSTALL_DIR} && wget -c ${GIBBON_URL} -P /tmp/ && tar -xzf /tmp/GibbonEduCore-InstallBundle.tar.gz --directory ${INSTALL_DIR} && \
    chown -R www-data:www-data ${INSTALL_DIR} && chmod -R 755 ${INSTALL_DIR} && chmod -R 774 ${INSTALL_DIR}uploads && \
    sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 51M/' /etc/php/8.1/apache2/php.ini && \
    a2dissite 000-default.conf && \
    # Cleanup temporary files and unnecessary packages
    rm -rf /tmp/* && apt-get purge --auto-remove -y wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Declare the volume after installing the application files
VOLUME ${INSTALL_DIR}

EXPOSE 80
CMD /usr/sbin/apache2ctl -D FOREGROUND
