# redis6-1.2.1

## 项目更新

1. 更新了版本命名模式
2. 引入github-action自动打包

## 版本更新

+ redis 7.0.3->6.2.7
+ RedisBloom 2.2.15->2.2.18

## 移除

+ RedisJSON
+ redistree

# v1.2.0

+ 新增插件RedisJSON
+ 新增插件redistree
+ 新增插件RedisTimeSeries
+ 修改dockerfile,改用cmd+默认配置文件的方式提高适应性
+ 新增不同部署方式的演示docker-compose及对应说明

# v1.1.0

+ 更新redis版本至redis 7
+ 新增插件RedisBloom
+ 新增插件redis-roaring
+ 新增插件RediSQL

# v1.0.0

基镜像[redis:6.2.4-alpine3.13](https://hub.docker.com/layers/redis/library/redis/6.2.4-alpine3.13/images/sha256-f10659f231d1af867625603ec3f2137c47d48df6cde05e70771cb1b3182d1e9c?context=explore)

## 使用插件

1. [redis-cell@v0.3.0](https://github.com/brandur/redis-cell/tree/v0.3.0)用于做限流器