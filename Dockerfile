FROM nginx:stable-alpine

COPY nginx-keys/ /tmp/nginx-keys
COPY compile.sh /tmp/compile.sh
RUN chmod +x /tmp/compile.sh && \
    /tmp/compile.sh && \
    rm -rf /tmp/*

COPY crowdsec/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh && \
    /tmp/install.sh && \
    rm -rf /tmp/*

COPY entrypoint/ /opt/entrypoint
COPY confs/ /opt/confs
COPY scripts/ /opt/scripts
COPY fail2ban/ /opt/fail2ban
COPY logs/ /opt/logs
COPY lua/ /opt/lua
COPY crowdsec/ /opt/crowdsec
COPY autoconf/ /opt/autoconf

RUN apk --no-cache add certbot libstdc++ libmaxminddb geoip pcre yajl fail2ban clamav apache2-utils rsyslog openssl lua libgd go jq mariadb-connector-c bash brotli py3-pip && \
    pip3 install docker && \
    chmod +x /opt/entrypoint/* /opt/scripts/* /opt/autoconf/autoconf.py && \
    mkdir /opt/entrypoint.d && \
    rm -f /var/log/nginx/* && \
    chown root:nginx /var/log/nginx && \
    chmod 750 /var/log/nginx && \
    touch /var/log/nginx/error.log /var/log/nginx/modsec_audit.log && \
    # chown nginx:nginx /var/log/nginx/*.log && \
    mkdir /acme-challenge && \
    chown root:nginx /acme-challenge && \
    chmod 750 /acme-challenge

# Fix CVE-2020-28928
RUN apk --no-cache add "musl-utils>1.1.24-r2"

VOLUME /www /http-confs /server-confs /modsec-confs /modsec-crs-confs /cache /var/log

EXPOSE 8080/tcp 8443/tcp

ENTRYPOINT ["/opt/entrypoint/entrypoint.sh"]
