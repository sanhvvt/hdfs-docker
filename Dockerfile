FROM openjdk:8u171-jre-alpine3.8

LABEL maintainer="cs" \
      organization="imcs.com"

ARG version=2.7.7
ENV HADOOP_VERSION=$version \
    HADOOP_PREFIX=/opt/hadoop \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    PATH=$PATH:/opt/hadoop/bin \
    MULTIHOMED_NETWORK=1 \
    CLUSTER_NAME=hadoop \
    HDFS_CONF_dfs_namenode_name_dir=file:///dfs/name \
    HDFS_CONF_dfs_datanode_data_dir=file:///dfs/data \
    USER=hdfs


RUN apk add --no-cache bash perl jruby curl && mkdir /opt && rm -rf /var/lib/apt/lists/* && \
    curl -SL https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar xvz -C /opt && \
    ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop && \
    # remove documentation from container image
    rm -r /opt/hadoop/share/doc 

RUN if [ ! -f $HADOOP_CONF_DIR/mapred-site.xml ]; then \
    cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml; \
    fi 

RUN addgroup -g 114 -S hadoop && \
    adduser -u 201 -s /bin/bash -H -S -G hadoop -h /var/lib/hadoop/hdfs hdfs && \
    mkdir -p /dfs && \
    mkdir -p /opt/hadoop/logs && \
    chown -R hdfs:hadoop /dfs && \
    chown -LR hdfs:hadoop /opt/hadoop
   
COPY entrypoint.sh /entrypoint.sh

USER hdfs
WORKDIR /opt/hadoop

VOLUME /dfs

EXPOSE 8020 

# HDFS 2.x web interface
EXPOSE 50070

# HDFS 3.x web interface
EXPOSE 9870

ENTRYPOINT ["/entrypoint.sh"]
