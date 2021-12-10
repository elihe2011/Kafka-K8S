# 1. 编译镜像

采用 3.0 版本，不再使用 zookeeper 做集群管理。采用奇数节点方式

```bash
cd image
docker build -t kafka:3.0.0 .
```



# 2. 存储准备

暂定本地磁盘存储

```bash
mkdir -p /data/kafka
```



# 3. 创建集群

```bash
cd ..
kubectl apply -f kafka.yml
```



# 4. 验证

## 4.1 kafkacat

```bash
# 安装测试工具
$ apt install kafkacat

# 获取 broker 列表
$ kafkacat -b 192.168.80.240:30090 -L
Metadata for all topics (from broker -1: 192.168.80.240:30090/bootstrap):
 3 brokers:
  broker 0 at 192.168.80.242:30090
  broker 1 at 192.168.80.241:30091 (controller)
  broker 2 at 192.168.80.240:30092
 0 topics:


# 发布消息
$ kafkacat -b 192.168.80.240:30090 -t topic -P
hello world
abc
kafka test

# 订阅消息
$ kafkacat -b 192.168.80.241:30091 -t topic -C
% Reached end of topic topic [0] at offset 12
hello world
% Reached end of topic topic [0] at offset 13
abc
% Reached end of topic topic [0] at offset 14
kafka test
```



## 4.2 kafka 脚本

```bash
$ kubectl exec -it kafka-0 -n kafka-cluster -- /bin/bash

> kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic test --bootstrap-server kafka-0.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-1.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-2.kafka-svc.kafka-cluster.svc.cluster.local:9092 

> kafka-console-producer.sh --topic test --broker-list kafka-0.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-1.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-2.kafka-svc.kafka-cluster.svc.cluster.local:9092

> kafka-console-consumer.sh --from-beginning --topic test --bootstrap-server kafka-0.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-1.kafka-svc.kafka-cluster.svc.cluster.local:9092,kafka-2.kafka-svc.kafka-cluster.svc.cluster.local:9092
```





参考资料：

https://adityasridhar.com/posts/how-to-easily-install-kafka-without-zookeeper  【主机安装kafka，不带ZK】

https://developer.ibm.com/tutorials/kafka-in-kubernetes/ 【kafka 安装到 k8s】

https://github.com/IBM/kraft-mode-kafka-on-kubernetes/blob/main/kubernetes/kafka.yml

https://blog.csdn.net/boling_cavalry/article/details/105466163

https://www.orchome.com/1903

https://segmentfault.com/a/1190000020715650

https://tsuyoshiushio.medium.com/configuring-kafka-on-kubernetes-makes-available-from-an-external-client-with-helm-96e9308ee9f4     【loadblancer】

https://blog.51cto.com/u_15127500/3790439  【kafkacat 使用】