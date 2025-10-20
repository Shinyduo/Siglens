FROM siglens/siglens:1.0.57

USER root
RUN apk add --no-cache nginx tini gettext # envsubst from gettext

# sensible defaults for the template
ENV SIG_QUERY_PORT=5122 \
    SIG_INGEST_PORT=8081 \
    SIG_DATA_PATH=/data

# add templates
COPY server.yaml.template /etc/siglens/server.yaml.template
COPY nginx.conf.template  /etc/nginx/nginx.conf.template

RUN mkdir -p /data /run/nginx

ENTRYPOINT ["/sbin/tini","--"]
CMD ["/bin/sh","-lc", "\
  # render server.yaml from template with explicit ports and data path \
  envsubst < /etc/siglens/server.yaml.template > /etc/siglens/server.yaml && \
  echo '--- BEGIN EFFECTIVE server.yaml ---' && cat /etc/siglens/server.yaml && echo '\n--- END EFFECTIVE server.yaml ---' && \
  # start siglens first (background) \
  /siglens/siglens --config /etc/siglens/server.yaml & \
  # render nginx with actual $PORT and start in foreground \
  envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx -g 'daemon off;' \
"]
