# Use the official lightweight Node.js 18 image.
# https://hub.docker.com/_/node
FROM node:20-alpine AS deps

# Create and change to the app directory.
WORKDIR /app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install dependencies using npm ci for reproducibility
RUN npm ci --silent

# Copy local code to the container image.
# Build stage (copy node_modules from deps to avoid re-installing)
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate && npm run build

# Ensure OpenSSL is available so Prisma can detect engine properly
# RUN apt-get update && apt-get install -y openssl libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# Generate Prisma client and build the app
# RUN npm run build

# Run the web service on container startup.
FROM node:20-alpine AS production
WORKDIR /usr/src/app
ENV PORT 8080
# ENV HOST 0.0.0.0
ENV NODE_ENV=production

# Copy the already-built artifacts and node_modules (which includes the generated Prisma client)
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma

# Ensure OpenSSL for Prisma runtime
RUN apt-get update && apt-get install -y openssl libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
CMD ["node", "dist/main.js"]