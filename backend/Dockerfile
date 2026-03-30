FROM node:18-alpine

# Backend Docker image for pet-care
WORKDIR /app

# Install only production dependencies by default (smaller image).
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

ENV NODE_ENV=production
EXPOSE 4000
CMD ["node", "index.js"]
