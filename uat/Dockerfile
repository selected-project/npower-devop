FROM nginx:stable-alpine3.21

# Create the vue-app directory
RUN mkdir -p /usr/share/nginx/html/vue-app

# Copy the dist.tar archive to the container
COPY dist.tar.gz /tmp/dist.tar.gz

# Extract dist.tar into vue-app
RUN tar -xf /tmp/dist.tar.gz -C /usr/share/nginx/html/vue-app && \
    rm /tmp/dist.tar.gz
