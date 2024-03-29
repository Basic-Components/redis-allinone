# redis-allinone

+ author: hsz
+ 镜像地址: <https://hub.docker.com/repository/docker/hsz1273327/redis-allinone>
+ github地址: <https://github.com/Basic-Components/redis-allinone>
+ 版本: redis7-1.2.1

带实用扩展的redis镜像,本分支针对*redis7*

## 使用范围

1. 对实时性要求较高但数据量以及系统稳定性要求不高的场合(单机模式)

## 环境介绍

+ 操作系统: debian-bullseye
+ 基镜像: redis:7.0.5-bullseye

收录实用插件包括:

1. [redis-cell@v0.3.0](https://github.com/brandur/redis-cell/tree/v0.3.0)用于做限流器.
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式
2. [RedisBloom](https://github.com/RedisBloom/RedisBloom)用于做布隆过滤器.
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式
3. [redis-roaring](https://github.com/aviggiano/redis-roaring),用于提供性能更好的bitmap
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式
4. [RediSQL@v1.1.1_9b110f](https://github.com/RedBeardLab/rediSQL/tree/v1.1.1),用于提供sql支持
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式

5. [RedisTimeSeries](https://github.com/RedisTimeSeries/RedisTimeSeries)
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式

6. [TairZset](https://github.com/alibaba/TairZset)
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式

7. [TairString](https://github.com/alibaba/TairString)
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式
8. [TairHash](https://github.com/alibaba/TairHash)
    + 可用范围:
        + 单机模式
        + 主从模式
        + 集群模式

## 使用方法

默认配置文件在镜像中的[/etc/redis-config/redis.conf](https://github.com/Basic-Components/redis-allinone/blob/master/conf/redis.conf);默认集群配置在镜像中的[/etc/redis-config/redis.cluster.conf](https://github.com/Basic-Components/redis-allinone/blob/master/conf/redis.cluster.conf),使用时如果要添加其他参数,需要覆盖dockerfile中的`cmd`,比如在`docker-compose`中配置`command: ["/etc/redis-config/redis.conf", "--requirepass", "admin"]`

### 单机模式

对应docker-compose为[docker-compose.standalone.yml](https://github.com/Basic-Components/redis-allinone/blob/master/docker-compose.standalone.yml)

1. 使用docker-compose启动`docker-compose -f docker-compose.standalone.yml up -d`

2. 进入容器调试`docker exec -it redis-allinone-redis-inone-1 /bin/sh`

3. 退出`docker-compose -f docker-compose.standalone.yml down`

### 主从模式

对应docker-compose为[docker-compose.mr.yml](https://github.com/Basic-Components/redis-allinone/blob/master/docker-compose.mr.yml)

1. 使用docker-compose启动`docker-compose -f docker-compose.mr.yml up -d`

2. 进入master容器调试`docker exec -it redis-allinone-redis-inone-master-1 /bin/sh`

3. 进入replica容器调试`docker exec -it redis-allinone-redis-inone-replica1-1 /bin/sh`

4. 退出`docker-compose -f docker-compose.mr.yml down`

### 哨兵模式

对应docker-compose为[docker-compose.sentinel.yml](https://github.com/Basic-Components/redis-allinone/blob/master/docker-compose.sentinel.yml),[sentinel.conf.temp](https://github.com/Basic-Components/redis-allinone/blob/master/sentinel/sentinel.conf.temp)为配置样例

1. 使用docker-compose启动`docker-compose -f docker-compose.sentinel.yml up -d`

2. 进入master容器调试`docker exec -it redis-allinone-redis-inone-master-1 /bin/sh`

3. 进入replica容器调试`docker exec -it redis-allinone-redis-inone-replica1-1 /bin/sh`

4. 退出`docker-compose -f docker-compose.sentinel.yml down`

### 集群模式

对应docker-compose为[docker-compose.cluster.yml](https://github.com/Basic-Components/redis-allinone/blob/master/docker-compose.cluster.yml),注意如果使用swarm集群请使用**host方式**部署

1. 使用docker-compose启动`docker-compose -f docker-compose.cluster.yml up -d`
2. 进入node1容器调试`docker exec -it redis-allinone-redis-node1-1 /bin/sh`
3. 建立集群`redis-cli --cluster create 192.168.55.11:6379 192.168.55.12:6379 192.168.55.13:6379 192.168.55.14:6379 192.168.55.15:6379 192.168.55.16:6379 --cluster-replicas 1`
4. 连接node1尝试`redis-cli -c`
5. 进入node2尝试`docker exec -it redis-allinone-redis-node2-1 /bin/sh`->`redis-cli -c`
6. 退出`docker-compose -f docker-compose.cluster.yml down`
