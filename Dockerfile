FROM node:20.10.0-slim as base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base as builder

WORKDIR /home/node/app
COPY package*.json ./

COPY . .
RUN pnpm install --prod --frozen-lockfile
# RUN pnpm install
RUN pnpm build

FROM base as runtime

ENV NODE_ENV=production
ENV PAYLOAD_CONFIG_PATH=dist/payload.config.js

WORKDIR /home/node/app
COPY package*.json  ./
COPY pnpm-lock.yaml ./

RUN pnpm install --prod --frozen-lockfile
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 3000

CMD ["node", "dist/server.js"]
