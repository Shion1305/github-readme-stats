# Use Node.js 22 as base image (matches the engine requirement in package.json)
FROM node:22-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (express is needed from devDependencies for self-hosting)
# Ignore scripts to avoid husky prepare script
RUN npm ci --ignore-scripts && npm cache clean --force

# Development image
FROM base AS dev
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 9000
CMD ["npm", "run", "test"]

# Production image
FROM base AS runner
WORKDIR /app

# Don't run as root
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Use non-root user
USER nodejs

# Expose port
EXPOSE 9000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["node", "express.js"]
