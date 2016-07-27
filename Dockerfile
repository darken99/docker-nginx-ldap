FROM alpine:edge

ENV NGINX_VERSION 1.11.3

# Install required software
RUN \
    apk add --no-cache pcre openldap dockerize && \
    apk add --no-cache --virtual build-dependencies build-base curl pcre-dev openssl-dev openldap-dev && \
    curl -s -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o /nginx.tar.gz && \
    curl -s -L https://github.com/kvspb/nginx-auth-ldap/archive/master.zip -o /nginx-auth-ldap.zip && \
    mkdir /var/log/nginx \
	&& mkdir /etc/nginx \
	&& tar -C ~/ -xzf /nginx.tar.gz \
	&& unzip -x /nginx-auth-ldap.zip -d ~/ \
	&& cd ~/nginx-${NGINX_VERSION} \
	&& ./configure \
		--add-dynamic-module=/root/nginx-auth-ldap-master \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-debug \
		--conf-path=/etc/nginx/nginx.conf \ 
		--sbin-path=/usr/sbin/nginx \ 
		--pid-path=/var/log/nginx/nginx.pid \ 
		--error-log-path=/var/log/nginx/error.log \ 
		--http-log-path=/var/log/nginx/access.log \ 
	&& make install \
	&& cd .. \
	&& rm -rf nginx-auth-ldap \
	&& rm -rf nginx-${NGINX_VERSION} && \
    apk del build-dependencies


EXPOSE 80 443

CMD ["dockerize","-stdout","/var/log/nginx/access.log","-stderr","/var/log/nginx/error.log","/usr/sbin/nginx","-g","daemon off;"]
