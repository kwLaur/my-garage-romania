FROM gradle:8.11.1-jdk21 AS build
WORKDIR /workspace
COPY settings.gradle .
COPY backend/build.gradle backend/build.gradle
COPY backend/src backend/src
RUN gradle :backend:bootJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/backend/build/libs/*.jar app.jar
RUN mkdir -p /app/uploads/receipts
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
