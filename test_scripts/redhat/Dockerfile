FROM registry.access.redhat.com/ubi8/ubi:8.1


COPY . /app


RUN chmod +x /app/build/couchbase_installer.sh
RUN cd /app && ls -l
EXPOSE 8091
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]