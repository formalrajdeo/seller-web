# -------------------------
# 1. Install dependencies
# -------------------------
FROM node:20-alpine AS deps

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

RUN npm run build


# -------------------------
# 3. Production image
# -------------------------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy only necessary files
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# If you use next.config.js runtime config
COPY --from=builder /app/next.config.js ./

EXPOSE 3000

CMD ["npm", "start"]