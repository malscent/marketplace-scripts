FROM debian:latest

COPY . /app


RUN chmod +x /app/main.sh
RUN cd /app && ls -l
EXPOSE 8091
ENTRYPOINT [ "/app/main.sh" ]