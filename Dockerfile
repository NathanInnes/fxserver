FROM alpine as builder

WORKDIR /output

RUN apk add git
RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/4394-572b000db3f5a323039e0915dac64641d1db408e/fx.tar.xz \
    | tar xJ --strip-components=1 \
    --exclude apline/dev --exclude apline/proc \
    --exclude alpine/run --exclude alpine/sys \
&&  mkdir -p /output/opt/cfx-server-data /output/usr/local/share \
&&  git clone https://github.com/citizenfx/cfx-server-data.git /output/opt/cfx-server-data \
&&  apk -p $PWD add tini

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

RUN chmod +x /output/usr/bin/entrypoint

#=====

FROM scratch

COPY --from=builder /output/ /

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]
ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
