# Use Eclipse Temurin JDK 21 as the base image
FROM eclipse-temurin:21-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file from Maven target directory
COPY target/*.jar app.jar

# Expose port 8080 (if your app runs on it)
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
