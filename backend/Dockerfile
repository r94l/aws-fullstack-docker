# ─────────────────────────────────────────
# Stage 1: Base
# ─────────────────────────────────────────
FROM node:18-alpine AS base

WORKDIR /app

COPY package*.json ./
COPY src/prisma ./src/prisma

# ─────────────────────────────────────────
# Stage 2: Dependencies
# ─────────────────────────────────────────
FROM base AS deps

RUN npm ci --only=production

# Generate Prisma client in production deps
RUN npx prisma generate --schema=src/prisma/schema.prisma

# ─────────────────────────────────────────
# Stage 3: Builder
# ─────────────────────────────────────────
FROM base AS builder

RUN npm ci

# Generate Prisma client
RUN npx prisma generate --schema=src/prisma/schema.prisma

COPY . .

# Build the app with NX
RUN npx nx build api --configuration=production

# ─────────────────────────────────────────
# Stage 4: Production
# ─────────────────────────────────────────
FROM node:18-alpine AS production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production dependencies WITH generated prisma client
COPY --from=deps /app/node_modules ./node_modules

# Copy built app from builder
COPY --from=builder /app/dist/api ./dist/api

# Copy prisma schema for migrations
COPY --from=builder /app/src/prisma ./src/prisma

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "dist/api/main.js"]
