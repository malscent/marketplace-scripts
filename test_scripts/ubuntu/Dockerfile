FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y python
COPY . /app
COPY ./test_scripts/docker/systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl
RUN test -L /bin/sysstemctl || ln -sf /usr/bin/systemctl /bin/systemctl
RUN chmod +x /app/build/couchbase_installer.sh
RUN cd /app && ls -l
EXPOSE 8091
CMD [ "/usr/bin/systemctl" ]
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]