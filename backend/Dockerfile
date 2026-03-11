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

# Install ALL dependencies including devDependencies
RUN npm ci

COPY . .

# Stage 4: Production
FROM node:18-alpine AS production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only production deps from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy built app from builder stage
COPY --from=builder /app .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "app.js"]