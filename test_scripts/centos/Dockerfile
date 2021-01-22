FROM centos:latest

COPY . /app
RUN yum -y install initscripts && yum clean all



RUN chmod +x /app/build/couchbase_installer.sh
RUN cd /app && ls -l
EXPOSE 8091
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]