# Use official SigLens image
FROM siglens/siglens:1.0.57

# Install nginx & bash (image is Alpine)
RUN apk add --no-cache nginx bash tini

# Add configs
COPY server.yaml /etc/siglens/server.yaml
COPY nginx.conf /etc/nginx/nginx.conf

# Create data dir for the Railway volume mount
RUN mkdir -p /data /run/nginx

# Expose internal SigLens ports (purely informational in Railway)
EXPOSE 5122 8081

# Use tini to supervise both processes
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "-lc", "\
  siglens --config /etc/siglens/server.yaml & \
  nginx -g 'daemon off;' \
"]
