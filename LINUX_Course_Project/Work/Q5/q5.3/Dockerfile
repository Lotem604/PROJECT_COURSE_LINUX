FROM openjdk:17

WORKDIR /app

COPY WaterMark.java .

RUN javac WaterMark.java

ENTRYPOINT ["java", "WaterMark"]