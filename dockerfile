FROM --platform=${TARGETPLATFORM} redis:7.0.3-bullseye as redisbloom_builder
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential && rm -rf /var/lib/apt/lists/*
# Build the source
WORKDIR /
# 本地打包用 RUN export ALL_PROXY=192.168.1.201:7890
RUN git clone -b ver2.2.15 --recursive https://github.com/RedisBloom/RedisBloom.git /build
WORKDIR /build
RUN ./deps/readies/bin/getpy2
RUN ./deps/readies/bin/getupdates
RUN ./system-setup.py

RUN bash -l -c "make all"


FROM --platform=${TARGETPLATFORM} redis:7.0.3-bullseye as redis-roaring_builder
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential cmake && rm -rf /var/lib/apt/lists/*
# Build the source
WORKDIR /
# 本地打包用 RUN export ALL_PROXY=192.168.1.201:7890
RUN git clone --recursive https://github.com/aviggiano/redis-roaring.git /build
WORKDIR /build
# RUN git submodule pull
RUN bash configure.sh




FROM --platform=${TARGETPLATFORM} redis:7.0.3-bullseye as build
ARG TARGETPLATFORM ${TARGETPLATFORM}
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
# ENV LIBDIR /plugins
WORKDIR /data
# RUN set -ex;\
#     mkdir -p "$LIBDIR";
# USER redis:redis
COPY --from=redisbloom_builder /build/redisbloom.so /etc/redis-plugins/redisbloom/redisbloom.so
RUN chmod +x /etc/redis-plugins/redisbloom/redisbloom.so
COPY ./cell/${TARGETPLATFORM}/libredis_cell.d /etc/redis-plugins/redis-cell/libredis_cell.d
COPY ./cell/${TARGETPLATFORM}/libredis_cell.so /etc/redis-plugins/redis-cell/libredis_cell.so
RUN chmod +x /etc/redis-plugins/redis-cell/libredis_cell.so
COPY --from=redis-roaring_builder /build/build/libredis-roaring.so /etc/redis-plugins/redisroaring/libredis-roaring.so
RUN chmod +x /etc/redis-plugins/redisroaring/libredis-roaring.so
COPY ./RediSQL/${TARGETPLATFORM}/redisql.so /etc/redis-plugins/redisql/redisql.so
RUN chmod +x /etc/redis-plugins/redisql/redisql.so
CMD [ "redis-server", "--loadmodule", "/etc/redis-plugins/redis-cell/libredis_cell.so", "--loadmodule", "/etc/redis-plugins/redisbloom/redisbloom.so","--loadmodule","/etc/redis-plugins/redisroaring/libredis-roaring.so", "--loadmodule", "/etc/redis-plugins/redisql/redisql.so"]