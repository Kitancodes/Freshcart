FROM node:24-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install -g npm@12.0.2
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build
RUN npm prune --omit=dev


FROM node:24-alpine AS runner

WORKDIR /app

RUN npm install -g npm@12.0.2

COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

USER node
CMD ["npm", "start"]