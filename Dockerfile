# ---- Stage 1: Base ----
FROM node:22-alpine AS base

# 使用阿里云镜像源加速 apk 包下载
RUN echo 'https://mirrors.aliyun.com/alpine/v3.20/main' > /etc/apk/repositories && \
    echo 'https://mirrors.aliyun.com/alpine/v3.20/community' >> /etc/apk/repositories && \
    apk add --no-cache libc6-compat && \
    corepack enable && corepack prepare pnpm@10.28.0 --activate

WORKDIR /app

# ---- Stage 2: Dependencies ----
FROM base AS deps

# Native build tools for sharp, @napi-rs/canvas
# 已在 base 阶段配置阿里云 apk 镜像，此处直接使用
RUN apk add --no-cache python3 build-base g++ cairo-dev pango-dev jpeg-dev giflib-dev librsvg-dev

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/

RUN pnpm install --frozen-lockfile

# ---- Stage 3: Builder ----
FROM base AS builder

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/packages ./packages
COPY . .

RUN pnpm build

# ---- Stage 4: Runner ----
FROM node:22-alpine AS runner

# 使用阿里云镜像源
RUN echo 'https://mirrors.aliyun.com/alpine/v3.20/main' > /etc/apk/repositories && \
    echo 'https://mirrors.aliyun.com/alpine/v3.20/community' >> /etc/apk/repositories && \
    apk add --no-cache libc6-compat cairo pango jpeg giflib librsvg

WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
