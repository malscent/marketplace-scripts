FROM registry.access.redhat.com/ubi8/ubi:8.3

COPY . /app
RUN yum update && yum -y install initscripts procps which hostname && yum clean all && rm -fr /var/cache 

COPY ./test_scripts/docker/systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl &&  chmod +x /app/build/couchbase_installer.sh
EXPOSE 8091
CMD [ "/usr/bin/systemctl" ]
ENTRYPOINT [ "/app/build/couchbase_installer.sh" ]