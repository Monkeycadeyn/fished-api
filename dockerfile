FROM node:18-alpine AS base

RUN npm i -g pnpm


FROM base AS dependencies

WORKDIR /fished-api
COPY package.json pnpm-lock.yaml ./
RUN pnpm install


FROM base AS build

WORKDIR /fished-api
COPY . .
COPY --from=dependencies /fished-api/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod


FROM base AS deploy

WORKDIR /fished-api
COPY --from=build /fished-api/dist/ ./dist/
COPY --from=build /fished-api/node_modules ./node_modules

EXPOSE 8080
CMD [ "node", "dist/main.js"]