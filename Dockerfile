FROM groovy:jdk8

MAINTAINER Ronnie Huang <RonnieHuang@outlook.com>

USER root

ARG JMETER_VERSION="5.2.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV     JMETER_BIN      ${JMETER_HOME}/bin
ENV     JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# Install extra packages
# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
# Change TimeZone TODO: TZ still is not set!
ARG TZ="Pacific/Auckland"
RUN    apt-get update \
        && apt-get -y upgrade \
        && apt-get install -y ca-certificates \
        && update-ca-certificates \
        && apt-get install -y tzdata curl unzip bash \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /tmp/dependencies  \
        && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
        && mkdir -p /opt  \
        && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
        && rm -rf /tmp/dependencies

# TODO: plugins (later)
#RUN    ls /opt/java/openjdk
COPY plugins/jpgc-cmd-2.2.zip /opt
RUN     unzip -oq "/opt/jpgc-cmd-2.2.zip" -d $JMETER_HOME


# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN:/opt/java/openjdk/bin

#WORKDIR        ${JMETER_HOME}

RUN set -o errexit -o nounset \
    && echo "Testing Groovy installation" \
    && groovy --version

RUN echo "Testing Jmeter version" \
    && jmeter -v

RUN echo "Testing Java version" \
    && java -version
