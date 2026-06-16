# -------------------------
# 1. Install dependencies
# -------------------------
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# -------------------------
# 2. Build Next.js app
# -------------------------
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Disables telemetry collection during build steps
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# -------------------------
# 3. Production image
# -------------------------
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create a system user to run Next safely without root privileges
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# 🛠️ FIXED: Uses a wildcard match so it catches next.config.js, next.config.mjs, or next.config.ts
COPY --from=builder /app/next.config.* ./

USER nextjs

EXPOSE 3000
ENV PORT=3000

CMD ["npm", "start"]