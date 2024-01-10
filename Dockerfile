# Use an official slim version of the Node image as a parent image
FROM node:slim 

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY app/package*.json ./

# Install any dependencies in the container
RUN npm install

# Copy the rest of your app's source code into the container
COPY app/ .

# Inform Docker that the container listens on port 80 at runtime
EXPOSE 80

# Define the command to run app (start the Node.js server)
CMD [ "node", "server.js" ]
