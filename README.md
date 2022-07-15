# redis-allinone

+ author: hsz
+ version: v1.1.0

带实用扩展的redis镜像

## 环境介绍

+ 操作系统: debian-bullseye
+ 基镜像: [redis:7.0.3-bullseye](https://hub.docker.com/layers/redis/library/redis/7.0.3-bullseye/images/sha256-ac68f247b2758660d03e52f5d2eb88a1ea12bb1b717d5f1a061715de6726e330?context=explore)

收录实用插件包括:

1. [redis-cell@v0.3.0](https://github.com/brandur/redis-cell/tree/v0.3.0)用于做限流器
2. [RedisBloom@v2.2.15](https://github.com/RedisBloom/RedisBloom/tree/ver2.2.15)用于做布隆过滤器
3. [redis-roaring](https://github.com/aviggiano/redis-roaring),用于提供性能更好的bitmap
4. [RediSQL@v1.1.1_9b110f](https://github.com/RedBeardLab/rediSQL/tree/v1.1.1),用于提供sql支持

## 使用方法

> 使用docker-compose启动`docker-compose up -d`

> 进入容器调试`docker exec -it redis-allinone-redis-inone-1 /bin/sh`

> 退出`docker-compose down`