#!/bin/bash

NODE_ID=${HOSTNAME: -1}
LISTENERS="CONTROLLER://0.0.0.0:9093,PLAINTEXT://0.0.0.0:9092,EXTERNAL://0.0.0.0:$((30090 + $NODE_ID))"
ADVERTISED_LISTENERS="PLAINTEXT://kafka-$NODE_ID.$SERVICE.$NAMESPACE.svc.cluster.local:9092,EXTERNAL://${K8S_NODE_IP}:$((30090 + $NODE_ID))"

CONTROLLER_QUORUM_VOTERS=""
for i in $( seq 0 $REPLICAS); do
    if [[ $i != $REPLICAS ]]; then
        CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093,"
    else
        CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS::-1}
    fi
done

mkdir -p $SHARE_DIR/$NODE_ID

sed -e "s+^node.id=.*+node.id=${NODE_ID}+" \
-e "s+^controller.quorum.voters=.*+controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS+" \
-e "s+^listeners=.*+listeners=$LISTENERS+" \
-e "s+^advertised.listeners=.*+advertised.listeners=$ADVERTISED_LISTENERS+" \
-e "s+\(^listener.security.protocol.map=.*\)+\1,EXTERNAL:PLAINTEXT+" \
-e "s+^log.dirs=.*+log.dirs=$SHARE_DIR/$NODE_ID+" \
/opt/kafka/config/kraft/server.properties > server.properties.updated \
&& mv server.properties.updated /opt/kafka/config/kraft/server.properties

/opt/kafka/bin/kafka-storage.sh format -t $CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties