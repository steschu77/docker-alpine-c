FROM alpine:edge

RUN apk --no-cache add cmake make yasm gcc libc-dev openssl-dev cppcheck binutils-gold ninja && rm /usr/bin/vsyasm /usr/bin/ytasm
RUN apk --no-cache add ccache ca-certificates wget && update-ca-certificates

ENV ENV=/etc/profile
COPY profile.sh /etc/profile.d/

CMD ["/bin/ash"]
