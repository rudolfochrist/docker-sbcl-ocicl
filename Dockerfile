FROM crapware/sbcl as build
LABEL "version"="2.5.12"

ENV OCICL_VERSION 2.5.12

RUN apt update && apt install -y \
    ca-certificates \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/src/ \
    && cd /usr/local/src \
    && curl -fsSLO https://github.com/ocicl/ocicl/archive/refs/tags/v${OCICL_VERSION}.tar.gz \
    && tar xf v${OCICL_VERSION}.tar.gz \
    && cd ocicl-${OCICL_VERSION} \
    && OCICL_PREFIX=/usr/local/ sbcl --load setup.lisp

FROM crapware/sbcl

RUN apt update && apt install -y \
    ca-certificates \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /root/.local /root/.local/
COPY --from=build /usr/local/bin/ocicl /usr/local/bin/

WORKDIR /root
RUN ocicl setup > .sbclrc \
    && sbcl --non-interactive --quit # preload caches

CMD ["/usr/local/bin/ocicl"]
