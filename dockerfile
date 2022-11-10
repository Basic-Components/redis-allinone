FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as redisbloom_builder
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /
RUN git clone -b v2.2.18 --recursive https://github.com/RedisBloom/RedisBloom.git /build
WORKDIR /build
RUN ./deps/readies/bin/getpy2
RUN ./deps/readies/bin/getupdates
RUN ./system-setup.py
RUN bash -l -c "make all"


FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as redis-roaring_builder
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential cmake && rm -rf /var/lib/apt/lists/*
WORKDIR /
RUN git clone --recursive https://github.com/aviggiano/redis-roaring.git /build
WORKDIR /build
RUN bash configure.sh

FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as redistimeseries_builder
RUN apt update -y && apt install -y --no-install-recommends ca-certificates curl git build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /
RUN git clone -b v1.6.16 --recursive https://github.com/RedisTimeSeries/RedisTimeSeries.git /build
WORKDIR /build
RUN ./deps/readies/bin/getpy3
RUN ./system-setup.py
RUN bash -l -c "make build"

FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as TairString_builder
ENV TAIRSTRING_URL https://github.com/alibaba/TairString.git
RUN set -ex; \
    \
    BUILD_DEPS=' \
        ca-certificates \
        cmake \
        gcc \
        git \
        g++ \
        make \
    '; \
    apt-get update; \
    apt-get install -y $BUILD_DEPS --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    git clone "$TAIRSTRING_URL"; \
    cd TairString; \
    mkdir -p build; \
    cd build; \
    cmake ..; \
    make -j; \
    cd ..; \
    cp lib/tairstring_module.so /usr/local/lib/; \
    \
    apt-get purge -y --auto-remove $BUILD_DEPS

FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as TairZset_builder
ENV TAIRZSET_URL https://github.com/alibaba/TairZset.git
RUN set -ex; \
    \
    BUILD_DEPS=' \
        ca-certificates \
        cmake \
        gcc \
        git \
        g++ \
        make \
    '; \
    apt-get update; \
    apt-get install -y $BUILD_DEPS --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    git clone "$TAIRZSET_URL"; \
    cd TairZset; \
    mkdir -p build; \
    cd build; \
    cmake ..; \
    make -j; \
    cd ..; \
    cp lib/tairzset_module.so /usr/local/lib/; \
    \
    apt-get purge -y --auto-remove $BUILD_DEPS

FROM --platform=${TARGETPLATFORM} redis:6.2.7-bullseye as img
ARG TARGETPLATFORM ${TARGETPLATFORM}
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
#redistimeseries
COPY --from=redistimeseries_builder /build/bin/redistimeseries.so /etc/redis-plugins/redistimeseries/redistimeseries.so
RUN chmod +x /etc/redis-plugins/redistimeseries/redistimeseries.so

#TairString
COPY --from=TairString_builder /usr/local/lib/tairstring_module.so /etc/redis-plugins/tairstring/tairstring_module.so
RUN chmod +x /etc/redis-plugins/tairstring/tairstring_module.so

#TairZset
COPY --from=TairZset_builder /usr/local/lib/tairzset_module.so /etc/redis-plugins/tairzset/tairzset_module.so
RUN chmod +x /etc/redis-plugins/tairzset/tairzset_module.so

# configs
COPY ./conf /etc/redis-config
# cmd
CMD ["/etc/redis-config/redis.conf"]