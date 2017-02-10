FROM handcraftedbits/nginx-unit-webhook:2.6.0-2
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG HUGO_VERSION=v0.18.1

COPY data /

RUN apk update && \
  apk add git go libc-dev make && \

  mkdir -p /opt/hugo && \
  mkdir -p /opt/gopath/src/github.com/spf13 && \
  cd /opt/gopath/src/github.com/spf13 && \
  git clone https://github.com/spf13/hugo && \
  cd hugo && \
  git checkout tags/${HUGO_VERSION} && \
  export GOPATH=/opt/gopath && \
  export PATH=$PATH:$GOPATH/bin && \

  make govendor gitinfo && \
  mv hugo /opt/hugo/hugo && \
  cd /opt && \
  rm -rf gopath && \

  apk del go libc-dev make

CMD [ "/bin/bash", "/opt/container/script/run-hugo.sh" ]
