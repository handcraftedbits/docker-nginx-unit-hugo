FROM handcraftedbits/nginx-unit-webhook:2.6.5
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG HUGO_VERSION=v0.28

COPY data /

RUN apk update && \
  apk add git go libc-dev make && \

  mkdir -p /opt/hugo && \
  mkdir -p /opt/gopath/src/github.com/gohugoio && \
  cd /opt/gopath/src/github.com/gohugoio && \
  git clone https://github.com/gohugoio/hugo && \
  cd hugo && \
  git checkout tags/${HUGO_VERSION} && \
  export GOPATH=/opt/gopath && \
  export PATH=$PATH:$GOPATH/bin && \

  make hugo && \
  mv hugo /opt/hugo/hugo && \
  cd /opt && \
  rm -rf gopath && \

  apk del go libc-dev make

CMD [ "/bin/bash", "/opt/container/script/run-hugo.sh" ]
