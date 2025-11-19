# Use the official lightweight Node.js 20 image.
# https://hub.docker.com/_/node
FROM node:20-alpine AS deps

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install dependencies using npm ci for reproducibility
RUN npm ci --silent

FROM node:20-alpine AS build

WORKDIR /usr/src/app

RUN apk add --no-cache openssl

COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .

RUN npx prisma generate && npm run build

FROM node:20-alpine AS production

WORKDIR /usr/src/app

RUN apk add --no-cache openssl

ENV PORT 8080
ENV NODE_ENV=production

COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package*.json ./
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/prisma ./prisma

EXPOSE 8080
CMD ["node", "dist/main.js"]