# --- Stage 1: Build the TypeScript code ---
FROM node:24-alpine AS builder
WORKDIR /usr/src/app

COPY package.json package-lock.json ./
# Installs ALL dependencies (including TypeScript)
RUN npm ci

COPY . .
RUN npm run build

# --- Stage 2: Production environment ---
FROM node:24-alpine
WORKDIR /usr/src/app

COPY package.json package-lock.json ./
# Installs ONLY production dependencies (keeps image small)
RUN npm ci --production

# Copy the compiled JS from the builder stage
COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 4000
CMD ["node", "dist/index.js"]

