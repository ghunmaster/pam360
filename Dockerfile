FROM ubuntu:latest

MAINTAINER "ghunmaster"

RUN apt-get update && apt-get -y install wget unzip
WORKDIR /opt/
ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN wget https://www.manageengine.com/privileged-access-management/6167/ManageEngine_PAM360_64bit.bin
RUN chmod 777 ManageEngine_PAM360_64bit.bin
RUN echo "USER_INSTALL_DIR=/opt/ManageEngine/PAM360" > silentp.txt
RUN echo "USER_INPUT_RESULT_0=1" >> silentp.txt
RUN echo "USER_INPUT_RESULT_5=0" >> silentp.txt
RUN echo "-fileOverwrite_<USER_INSTALL_DIR>/_ManageEngine Password Manager Pro_installation/Change ManageEngine PAM360 Installation.lax=Yes" >> silentp.txt
RUN ./ManageEngine_PAM360_64bit.bin -i silent -f silentp.txt
RUN rm -rf ManageEngine_PAM360_64bit.bin
#RUN chown -R postgres:postgres /opt/ManageEngine/PAM360/
#RUN chmod -R 750 /opt/ManageEngine/PAM360/
#RUN chmod 700 /opt/ManageEngine/PAM360/pgsql/data/
#RUN chmod 777 /opt/ManageEngine/PAM360/logs/
RUN /opt/ManageEngine/PAM360/jre/bin/keytool -genkey -alias pam360 -keyalg RSA -keypass passtrix -storepass passtrix -keystore /opt/ManageEngine/PAM360/conf/server.keystore  -dname "CN=PAM360, OU=ManageEngine PAM360, O=ZOHO Corp., L=Pleasanton, S=CA, C=US" -keysize 2048 -validity 3650 2> /dev/null 1> /opt/ManageEngine/PAM360/conf/cert.err
#RUN chmod 0600 /opt/ManageEngine/PAM360/conf/ServerKey.key
#COPY ./docker-entrypoint.sh /opt/
RUN echo '#!/bin/sh' > docker-entrypoint.sh
#RUN echo "sh pam360-service start" >> docker-entrypoint.sh
RUN echo 'chown postgres:postgres /opt/ManageEngine/' >> docker-entrypoint.sh
RUN echo 'chown -R postgres:postgres /opt/ManageEngine/PAM360/' >> docker-entrypoint.sh
RUN echo 'chmod -R 777 /opt/ManageEngine/PAM360/logs/' >> docker-entrypoint.sh
RUN echo 'chmod -R 750 /opt/ManageEngine/PAM360/' >> docker-entrypoint.sh
RUN echo 'chmod 700 /opt/ManageEngine/PAM360/pgsql/data/' >> docker-entrypoint.sh
RUN echo 'chmod 777 /opt/ManageEngine/PAM360/logs/' >> docker-entrypoint.sh
RUN echo 'chmod 0600 /opt/ManageEngine/PAM360/conf/ServerKey.key' >> docker-entrypoint.sh
#RUN echo runuser postgres -c "sh app_ctl.sh run"
RUN echo 'exec "$@"' >> docker-entrypoint.sh
RUN chmod 777 docker-entrypoint.sh
#RUN chmod 777 /opt/ManageEngine/PAM360/bin/docker-entrypoint.sh
#USER postgres
WORKDIR /opt/ManageEngine/PAM360/bin/
#CMD sh /opt/docker-entrypoint.sh
#ENTRYPOINT ["/bin/sh", "-c", "/opt/ManageEngine/PAM360/bin/pam360-service start" ]
#CMD ["/usr/sbin/runuser", "postgres", "-c", "sh pam360-service start"]
#CMD /usr/sbin/runuser postgres -c "./pam360-service start &"
#CMD "./pam360-service start &"
ENTRYPOINT [ "/opt/docker-entrypoint.sh" ]
CMD runuser postgres -c "sh app_ctl.sh run"
#ENTRYPOINT ["/opt/ManageEngine/PAM360/bin/docker-entrypoint.sh" ]
