# Ubuntu 24.04 (noble) images. The default Ubuntu 26.04 images include /usr/bin/pebble,
# a Go program with known vulnerabilities that the image scan reports.
ARG JAVA_VERSION=25
FROM eclipse-temurin:${JAVA_VERSION}-jdk-noble AS build
WORKDIR /workspace
COPY . .
RUN ./mvnw -B -q -DskipTests package

FROM eclipse-temurin:${JAVA_VERSION}-jre-noble
WORKDIR /app
COPY --from=build /workspace/target/books.jar /app/books.jar
USER 1000
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/books.jar"]
