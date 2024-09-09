# 1. Use an official Node.js runtime as the base image
FROM node:18-alpine AS builder

# 2. Set the working directory in the container
WORKDIR /app

# 3. Copy the package.json and package-lock.json files
COPY package*.json ./

# 4. Install dependencies
RUN npm install

# 5. Copy the rest of the application files
COPY . .

# 6. Build the Next.js application
RUN npm run build

# 7. Install `serve` to serve the static files
RUN npm install -g serve

# 8. Create a non-root user to run the application
RUN addgroup -g 1001 -S nextjs && \
    adduser -S nextjs -u 1001 -G nextjs

# 9. Use an official Node.js runtime for the production stage
FROM node:18-alpine AS runner

# 10. Set the working directory in the container
WORKDIR /app

# 11. Copy the built application files from the builder stage
COPY --from=builder /app/.next /app/.next
COPY --from=builder /app/public /app/public
COPY --from=builder /app/package.json /app/package.json

# 12. Install only production dependencies
RUN npm install --only=production

# 13. Set the user to non-root
USER nextjs

# 14. Expose the port that the application will run on
EXPOSE 3000

# 15. Start the Next.js application
CMD ["npx", "serve", "-s", "out", "-l", "3000"]
