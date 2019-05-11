FROM nginx:alpine AS builder

# nginx:alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.15.0

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget https://github.com/kvspb/nginx-auth-ldap/archive/master.zip -O nginx-auth-ldap.zip

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  build-base \
  curl \
  pcre-dev \
  openldap-dev \
  zlib-dev

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
	tar -zxC /usr/src -f nginx.tar.gz && \
  unzip -x "nginx-auth-ldap.zip" -d "$(pwd)/" && \
  LDAPDIR="$(pwd)/nginx-auth-ldap-master" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --add-dynamic-module=$LDAPDIR && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  install -m755 objs/ngx_http_auth_ldap_module.so /usr/lib/nginx/modules/ngx_http_auth_ldap_module.so && \
  strip /usr/lib/nginx/modules/*.so


FROM nginx:alpine

# Install dependencies
RUN apk add --no-cache libldap

COPY ngx_http_auth_ldap_module.nginx /etc/nginx/modules.d/

RUN mkdir -p /etc/nginx/modules.d/ && \
    echo "include /etc/nginx/modules.d/*.conf;" >> /etc/nginx/nginx.conf

# Extract the dynamic module from the builder image
COPY --from=builder /usr/lib/nginx/modules/ngx_http_auth_ldap_module.so /usr/lib/nginx/modules/ngx_http_auth_ldap_module.so
