# ─────────────────────────────────────────
# Stage 1: Base
# ─────────────────────────────────────────
FROM node:18-slim AS base

WORKDIR /app

COPY package*.json ./
COPY src/prisma ./src/prisma

# ─────────────────────────────────────────
# Stage 2: Dependencies
# ─────────────────────────────────────────
FROM base AS deps

RUN npm ci --only=production

RUN npx prisma generate --schema=src/prisma/schema.prisma

# ─────────────────────────────────────────
# Stage 3: Builder
# ─────────────────────────────────────────
FROM base AS builder

RUN npm ci

RUN npx prisma generate --schema=src/prisma/schema.prisma

COPY . .

RUN npx nx build api --configuration=production

# ─────────────────────────────────────────
# Stage 4: Production
# ─────────────────────────────────────────
FROM node:18-slim AS production

# Install OpenSSL for Prisma
RUN apt-get update -y && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist/api ./dist/api
COPY --from=builder /app/src/prisma ./src/prisma

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=10 \
  CMD node -e "require('net').createConnection(3000, 'localhost').on('connect', () => process.exit(0)).on('error', () => process.exit(1))"

CMD ["node", "dist/api/main.js"]
