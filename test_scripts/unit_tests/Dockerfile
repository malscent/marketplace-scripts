FROM ubuntu:18.04
# TODO:  Use build args to version bats, bats-support, and bats-assert.  
RUN apt-get update && apt-get install -y python procps git && apt-get clean
ADD https://github.com/bats-core/bats-core/archive/refs/tags/v1.3.0.tar.gz /bats/
ADD https://github.com/ztombol/bats-support/archive/refs/tags/v0.3.0.tar.gz /bats/bats-support/
ADD https://github.com/ztombol/bats-assert/archive/refs/tags/v0.3.0.tar.gz /bats/bats-assert/
RUN tar -xzvf /bats/v1.3.0.tar.gz -C /bats/ && \
    /bats/bats-core-1.3.0/install.sh /usr/local &&  \
    rm -rf /bats/v1.3.0.tar.gz && \
    mkdir -p /usr/local/lib/bats-support && \
    tar -xzvf /bats/bats-support/v0.3.0.tar.gz -C /usr/local/lib/bats-support/ &&  \
    rm -rf /bats/bats-support/v0.3.0.tar.gz && \
    mv /usr/local/lib/bats-support/bats-support-0.3.0/* /usr/local/lib/bats-support/ && \
    mkdir -p /usr/local/lib/bats-assert && \
    tar -xzvf /bats/bats-assert/v0.3.0.tar.gz -C /usr/local/lib/bats-assert/ && \
    rm -rf /bats/bats-assert/v0.3.0.tar.gz && \
    mv /usr/local/lib/bats-assert/bats-assert-0.3.0/* /usr/local/lib/bats-assert/
COPY . /test/
CMD [ "/usr/local/bin/bats", "/test/test_scripts/unit_tests/"]