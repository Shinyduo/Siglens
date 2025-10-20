FROM siglens/siglens:1.0.57

# become root to install tools
USER root
RUN apk add --no-cache nginx tini gettext  # gettext provides envsubst

# add configs (keep nginx template separate)
COPY server.yaml /etc/siglens/server.yaml
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# dirs
RUN mkdir -p /data /run/nginx

# use tini to supervise both processes
ENTRYPOINT ["/sbin/tini","--"]
CMD ["/bin/sh","-lc", "\
  /siglens/siglens --config /etc/siglens/server.yaml & \
  envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx -g 'daemon off;' \
"]
