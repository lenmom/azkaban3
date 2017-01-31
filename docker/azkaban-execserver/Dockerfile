# VERSION 1.0

FROM java:8

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
# Work around initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No


## Install Azkaban exec server ################################

ARG AZK_VERSION
ENV AZK_VERSION ${AZK_VERSION:-3.1.0}
ENV AZK_HOME /home/azkaban-exec-server

ADD dist/azkaban-exec-server-${AZK_VERSION}.tar.gz /
RUN mv /azkaban-exec-server-${AZK_VERSION} $AZK_HOME

RUN mkdir -p $AZK_HOME/logs/ \
    && mkdir -p $AZK_HOME/conf/ \
    && mkdir -p $AZK_HOME/extlib/ \
    && mkdir -p $AZK_HOME/jobs/ \
    && mkdir -p $AZK_HOME/plugins/jobtypes/ \
    # Work around to run container as a daemon
    && sed -i "s/&//" $AZK_HOME/bin/azkaban-executor-start.sh 

ADD dist/mysql-connector-java-*.jar $AZK_HOME/extlib/
ADD conf/azkaban.properties $AZK_HOME/conf/

EXPOSE 12321
VOLUME $AZK_HOME/jobs


## Run container ###############################################

ADD script/run.sh $AZK_HOME/run.sh
RUN chmod +x $AZK_HOME/run.sh

WORKDIR $AZK_HOME
CMD ["./run.sh"]
