# Use the official lightweight Node.js 20 alpine image as the base for building.
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install build dependencies (python, compiler, openssl) required for native modules and Prisma
RUN apk add --no-cache python3 make g++ openssl && \
    npm config set python /usr/bin/python3

# Copy dependency manifests first for better caching
COPY package*.json ./
COPY prisma ./prisma/

# Install all dependencies (including devDependencies) to perform the build
RUN npm ci

# Copy the rest of the source code
COPY . .

# Generate Prisma client and build the NestJS application
RUN npx prisma generate && npm run build

# Remove development dependencies to reduce final image size
RUN npm prune --omit=dev

# Production stage - minimal runtime image
FROM node:20-alpine AS production

WORKDIR /usr/src/app

# Set environment variables
ENV PORT=8080
ENV NODE_ENV=production

# Install runtime dependencies (OpenSSL is needed by Prisma Client)
RUN apk add --no-cache openssl

# Copy runtime artifacts from the builder stage with correct ownership
# The 'node' user (UID 1000) is pre-configured in the official alpine image
COPY --from=builder --chown=node:node /usr/src/app/dist ./dist
COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=node:node /usr/src/app/package*.json ./
COPY --from=builder --chown=node:node /usr/src/app/prisma ./prisma

# Switch to the non-root 'node' user for security
USER node

EXPOSE 8080

# Start the application
CMD ["node", "dist/main.js"]