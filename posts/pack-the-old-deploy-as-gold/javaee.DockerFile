FROM amazoncorretto:8

EXPOSE 8080
COPY "jboss-4.2.3.GA" "/opt/jboss"
COPY "myapp" "/opt/jboss/server/default/deploy/myapp.war"

RUN find /opt/jboss | grep myapp

# ENTRYPOINT ["/opt/jboss/bin/run.sh"]
ENTRYPOINT ["/opt/jboss/bin/run.sh", "-b", "0.0.0.0"]
