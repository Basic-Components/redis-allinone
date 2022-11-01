docker buildx build --push --platform=linux/arm64,linux/amd64 \
-t hsz1273327/redis-allinone:redis7-1.2.1 \
-t hsz1273327/redis-allinone:redis7-latest \
-f dockerfile.cn .
