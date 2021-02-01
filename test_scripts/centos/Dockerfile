FROM centos:latest

COPY . /app
RUN yum -y install initscripts && yum clean all

COPY ./test_scripts/docker/systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl

RUN chmod +x /app/build/couchbase_installer.sh
RUN cd /app && ls -l
EXPOSE 8091
CMD [ "/usr/bin/systemctl" ]
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]