FROM centos:8

COPY . /app
RUN yum update && yum -y install initscripts procps which && yum clean all && rm -fr /var/cache

COPY ./test_scripts/docker/systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl && chmod +x /app/build/couchbase_installer.sh

EXPOSE 8091
CMD [ "/usr/bin/systemctl" ]
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]