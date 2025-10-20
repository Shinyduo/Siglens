FROM siglens/siglens:1.0.57

# Become root so we can install packages
USER root

# Install nginx + tini (bash optional)
RUN apk add --no-cache nginx tini

# Configs
COPY server.yaml /etc/siglens/server.yaml
COPY nginx.conf /etc/nginx/nginx.conf

# Data dir + nginx runtime dir
RUN mkdir -p /data /run/nginx && chown -R root:root /data /run/nginx

# Expose internal SigLens ports (informational on Railway)
EXPOSE 5122 8081

# Use tini to supervise both processes
ENTRYPOINT ["/sbin/tini","--"]
CMD ["/bin/sh","-lc","siglens --config /etc/siglens/server.yaml & nginx -g 'daemon off;'"]
