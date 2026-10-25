ARG JAVA_VERSION=25
FROM eclipse-temurin:${JAVA_VERSION}-jdk AS build
WORKDIR /workspace
COPY . .
RUN ./mvnw -B -q -DskipTests package

FROM eclipse-temurin:${JAVA_VERSION}-jre
WORKDIR /app
COPY --from=build /workspace/target/books.jar /app/books.jar
USER 1000
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/books.jar"]
