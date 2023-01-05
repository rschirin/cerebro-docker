# FROM amazoncorretto:17.0.5
FROM amazoncorretto:17.0.5 as builder

ARG CEREBRO_VERSION=0.9.4

RUN  yum update \
 && yum install -y wget tar gzip \
 && mkdir -p /opt/cerebro/logs \
 && wget -qO- https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
  | tar xzv --strip-components 1 -C /opt/cerebro \
 && sed -i '/<appender-ref ref="FILE"\/>/d' /opt/cerebro/conf/logback.xml

FROM amazoncorretto:17.0.5

COPY --from=builder /opt/cerebro /opt/cerebro

RUN yum install -y shadow-utils.x86_64 \
 && groupadd --gid 1000 cerebro \
 && adduser --system --no-create-home --shell /usr/bin/nologin --gid 1000 --uid 1000 cerebro \
 && chown -R root:root /opt/cerebro \
 && chown -R cerebro:cerebro /opt/cerebro/logs \
 && chown cerebro:cerebro /opt/cerebro

WORKDIR /opt/cerebro
USER cerebro

ENTRYPOINT [ "/opt/cerebro/bin/cerebro" ]

# ADD ./run.sh /cleafy/c4c-monitoring/tools/

# RUN chmod +x /cleafy/c4c-monitoring/tools/run.sh
# ENTRYPOINT [ "/cleafy/c4c-monitoring/tools/run.sh" ]