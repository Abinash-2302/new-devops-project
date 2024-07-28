# Use Node.js base image
FROM node:14

# Set the working directory
WORKDIR /app

# Copy the backend files
COPY . .

# Install dependencies
RUN npm install

# Expose the port
EXPOSE 3000

# Run the application
CMD ["node", "server.js"]

