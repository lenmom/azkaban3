# VERSION 1.0

FROM java:8

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
# Work around initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No


## Define default runtime ENV #################################

ENV AZK_NAME		Azkaban-Web
ENV AZK_LABEL		Local
ENV AZK_COLOR		#FF3061
ENV MYSQL_HOST		localhost
ENV MYSQL_PORT		3306
ENV MYSQL_DB		azkaban
ENV MYSQL_USER		azkaban
ENV MYSQL_PASSWORD	azkaban

## Install Azkaban web server ################################

ARG AZK_VERSION
ENV AZK_VERSION ${AZK_VERSION:-3.1.0}
ENV AZK_HOME /home/azkaban-web-server

ADD dist/azkaban-web-server-${AZK_VERSION}.tar.gz /
RUN mv /azkaban-web-server-${AZK_VERSION} $AZK_HOME

RUN mkdir -p $AZK_HOME/logs/ \
    && mkdir -p $AZK_HOME/conf/ \
    && mkdir -p $AZK_HOME/extlib/ \
    # Work around to run container as a daemon
    && sed -i "s/&//" $AZK_HOME/bin/azkaban-web-start.sh 

ADD dist/mysql-connector-java-*.jar $AZK_HOME/extlib/
ADD conf/azkaban.properties $AZK_HOME/conf/

EXPOSE 8081


## Run container ##############################################

ADD script/run.sh $AZK_HOME/run.sh
RUN chmod +x $AZK_HOME/run.sh

WORKDIR $AZK_HOME
CMD ["./run.sh"]

