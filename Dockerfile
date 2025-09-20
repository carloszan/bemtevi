# Builder stage
FROM node:22.1.0-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --only=production

# Runner stage
FROM node:22.19.0-alpine AS runner

WORKDIR /usr/src/app

# Install dependencies only for production
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package*.json ./

# Copy built application (assuming you build locally before docker build)
COPY dist ./dist

# Environment variables
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

ARG REDIS_HOST=host.docker.internal
ENV REDIS_HOST=${REDIS_HOST}

ARG REDIS_PORT=6379
ENV REDIS_PORT=${REDIS_PORT}

ARG REDIS_AUTH_PASS=''
ENV REDIS_AUTH_PASS=${REDIS_AUTH_PASS}

EXPOSE 3000

USER node

CMD ["node", "dist/main"]