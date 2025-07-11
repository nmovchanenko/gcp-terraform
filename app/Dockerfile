# ---- Base ----
# Use a specific Node.js version on Alpine Linux for a small, secure base
FROM node:22-alpine AS base
WORKDIR /app

# ---- Dependencies ----
# Create a dedicated stage for installing all dependencies.
# This layer is cached and only re-run when package.json or lock file changes.
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci

# ---- Build ----
# Create a dedicated stage for building the application.
# This layer is cached and only re-run when source code changes.
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ---- Production ----
# The final stage starts fresh from the base image for a clean, small result.
FROM base AS production
ENV NODE_ENV=production
ENV PORT=8080

# Copy package files and install ONLY the production dependencies.
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

# Copy the compiled application output from the 'build' stage.
COPY --from=build /app/build ./build

EXPOSE 8080

# The command to start the Node.js server produced by the SvelteKit adapter.
CMD ["node", "build"]
