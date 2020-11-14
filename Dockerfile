FROM groovy:jdk8

MAINTAINER Ronnie Huang <RonnieHuang@outlook.com>

USER root

ARG JMETER_VERSION="5.2.1"
ARG JMETER_PLUGINS_MANAGER_VERSION='1.4'
ARG CMDRUNNER_VERSION='2.2'
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

#RUN    ls /opt/java/openjdk

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

# jmeter plugins
RUN cd /tmp/ \
 && curl --location --silent --show-error --output ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
 && curl --location --silent --show-error --output ${JMETER_HOME}/lib/cmdrunner-${CMDRUNNER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/${CMDRUNNER_VERSION}/cmdrunner-${CMDRUNNER_VERSION}.jar \
 && java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
 && PluginsManagerCMD.sh install \
jpgc-jmxmon=0.3,\
jpgc-json=2.7,\
jpgc-perfmon=2.1,\
jpgc-xml=0.1,\
tilln-iso8583=1.1,\
tilln-sshmon=1.2,\
tilln-wssecurity=1.7,\
 && PluginsManagerCMD.sh status \
 && chmod +x ${JMETER_HOME}/bin/*.sh \
 && rm -fr /tmp/*

# use sh to launch if master or agent
COPY scripts/launch.sh ${JMETER_BIN}
RUN chmod 0755 ${JMETER_BIN}/launch.sh

EXPOSE 60000 1099 50000

ENTRYPOINT ["/opt/launch.sh"]