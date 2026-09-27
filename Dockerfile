FROM eclipse-temurin:25-jdk AS build
WORKDIR /workspace
COPY . .
RUN ./mvnw -B -q -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/target/books.jar /app/books.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/books.jar"]
