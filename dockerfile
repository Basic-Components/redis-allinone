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

FROM --platform=${TARGETPLATFORM} rust:1.62.0-slim-bullseye as redisjson_builder
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential libclang-dev && rm -rf /var/lib/apt/lists/*
# Build the source
WORKDIR /
# 本地打包用 RUN export ALL_PROXY=192.168.1.201:7890
RUN git clone --recursive -b v2.0.9 https://github.com/RedisJSON/RedisJSON.git /build
WORKDIR /build
# RUN git submodule pull
RUN cargo build --release

FROM --platform=${TARGETPLATFORM} rust:1.62.0-slim-bullseye as redistree_builder
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential libclang-dev && rm -rf /var/lib/apt/lists/*
# Build the source
WORKDIR /
# 本地打包用 RUN export ALL_PROXY=192.168.1.201:7890
RUN git clone --recursive -b v0.1.0 https://github.com/OhBonsai/RedisTree.git /build
WORKDIR /build
# RUN git submodule pull
RUN cargo build --release


FROM --platform=${TARGETPLATFORM} redis:7.0.3-bullseye as redistimeseries_builder
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential && rm -rf /var/lib/apt/lists/*
# Build the source
WORKDIR /
# 本地打包用 RUN export ALL_PROXY=192.168.1.201:7890
RUN git clone -b v1.6.16 --recursive https://github.com/RedisTimeSeries/RedisTimeSeries.git /build
WORKDIR /build
RUN ./deps/readies/bin/getpy3
RUN ./system-setup.py
RUN bash -l -c "make build"


FROM --platform=${TARGETPLATFORM} redis:7.0.3-bullseye as img
ARG TARGETPLATFORM ${TARGETPLATFORM}
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y && apt install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /data
#redisbloom
COPY --from=redisbloom_builder /build/redisbloom.so /etc/redis-plugins/redisbloom/redisbloom.so
RUN chmod +x /etc/redis-plugins/redisbloom/redisbloom.so
#cell
COPY ./cell/${TARGETPLATFORM}/libredis_cell.d /etc/redis-plugins/redis-cell/libredis_cell.d
COPY ./cell/${TARGETPLATFORM}/libredis_cell.so /etc/redis-plugins/redis-cell/libredis_cell.so
RUN chmod +x /etc/redis-plugins/redis-cell/libredis_cell.so
#libredis-roaring
COPY --from=redis-roaring_builder /build/build/libredis-roaring.so /etc/redis-plugins/redisroaring/libredis-roaring.so
RUN chmod +x /etc/redis-plugins/redisroaring/libredis-roaring.so
#redisql
COPY ./RediSQL/${TARGETPLATFORM}/redisql.so /etc/redis-plugins/redisql/redisql.so
RUN chmod +x /etc/redis-plugins/redisql/redisql.so
#redisjson
COPY --from=redisjson_builder /build/target/release/librejson.so /etc/redis-plugins/redisjson/librejson.so
RUN chmod +x /etc/redis-plugins/redisjson/librejson.so
#redistree
COPY --from=redistree_builder /build/target/release/libretree.so /etc/redis-plugins/libretree/libretree.so
RUN chmod +x /etc/redis-plugins/libretree/libretree.so
#redistimeseries
COPY --from=redistimeseries_builder /build/bin/redistimeseries.so /etc/redis-plugins/redistimeseries/redistimeseries.so
RUN chmod +x /etc/redis-plugins/redistimeseries/redistimeseries.so
# configs
COPY ./conf /etc/redis-config
# cmd
CMD ["/etc/redis-config/redis.conf"]