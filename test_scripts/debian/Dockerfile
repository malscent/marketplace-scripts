FROM debian:latest

COPY . /app
COPY ./test_scripts/docker/systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl
RUN test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl
RUN apt-get update && apt-get install procps -y  && apt-get clean
RUN chmod +x /app/build/couchbase_installer.sh
EXPOSE 8091
CMD [ "/usr/bin/systemctl" ]

ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]