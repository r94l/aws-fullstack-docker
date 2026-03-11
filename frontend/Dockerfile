# Stage 1: Base
FROM node:18-alpine AS base

WORKDIR /app

COPY package*.json ./

# Stage 2: Dependencies
FROM base AS deps

# Install only production dependencies
RUN npm ci --only=production

# Stage 3: Builder
FROM base AS builder

# Install ALL dependencies including devDependencies needed for build
RUN npm ci

COPY . .

# Build React app into static files
RUN npm run build

# Stage 4: Production (Nginx serves static files)
FROM nginx:alpine AS production

# Copy built static files from builder
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx config for React routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]