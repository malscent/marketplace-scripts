FROM ubuntu:18.04

COPY . /app


RUN chmod +x /app/main.sh
RUN cd /app && ls -l
EXPOSE 8091
ENTRYPOINT [ "/app/main.sh" ]