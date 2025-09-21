# Stage 1: Build
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 build-base

# Copy package files
COPY package*.json ./

# Install dependencies (with clean cache)
RUN npm ci

# Copy rest of project files
COPY . .

# Build Next.js app
RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Copy only the standalone build from builder
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Run Next.js standalone server
CMD ["node", "server.js"]
