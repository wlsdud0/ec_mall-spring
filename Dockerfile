FROM eclipse-temurin:17

WORKDIR /app
COPY 게시판 .

RUN <<EOF
./gradlew bootJar
mv build/libs/*.jar app.jar
EOF

CMD ["java", "-jar", "app.jar"]

EXPOSE 8080
