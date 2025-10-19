FROM node:18 AS builder

WORKDIR /usr/src/app

# Copy frontend package files and install ALL deps for build (including devDependencies)
COPY frontend/package*.json ./
RUN npm ci

# Copy source and build the frontend
COPY frontend/ .
RUN npm run build

FROM node:18-alpine

LABEL org.opencontainers.image.source https://github.com/simpleace15/ServerManagerIPMI

EXPOSE 8080

# Install ipmitool runtime deps
RUN apk add --no-cache ipmitool musl-dev gcc g++ make

WORKDIR /usr/src/app

# Copy backend package files and install ONLY production deps
COPY backend/package*.json ./
RUN npm ci --only=production

# Copy backend source
COPY backend/src ./src

# Copy frontend build from builder
COPY --from=builder /usr/src/app/build ./build

CMD [ "npm", "start" ]