FROM debian:stretch

# Superset version
ARG SUPERSET_VERSION=0.22.1
ARG proxy
ENV http_proxy $proxy
ENV https_proxy $proxy

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset 

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        openjdk-8-jdk \
	unixodbc-dev \
        python3-dev \
        python3-pip
RUN pip3 install `echo $proxy | sed 's/\(\S\S*\)/--proxy \1/'` \
        flask-cors==3.0.3 \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyathenajdbc==1.2.0 \
        pyhive==0.5.0 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        sqlalchemy-clickhouse==0.1.1.post3 \
        Werkzeug==0.12.1 \
        sqlalchemy-vertica-python \
        superset==${SUPERSET_VERSION}

# Configure Filesystem
COPY superset /usr/local/bin

VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

#COPY vertica-client-9.0.0-1.x86_64.tar.gz /tmp/vertica.tgz
#RUN tar xzf /tmp/vertica.tgz -C / && rm /tmp/vertica.tgz

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset"]
CMD ["runserver"]
USER superset
