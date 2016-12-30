FROM handcraftedbits/nginx-unit-webhook:2.6.0
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG HUGO_VERSION=v0.18

COPY data /

RUN apk update && \
  apk add git go make && \

  mkdir -p /opt/hugo && \
  mkdir -p /opt/gopath/src/github.com/spf13 && \
  cd /opt/gopath/src/github.com/spf13 && \
  git clone https://github.com/spf13/hugo && \
  cd hugo && \
  git checkout tags/${HUGO_VERSION} && \
  export GOPATH=/opt/gopath && \

  go get github.com/BurntSushi/toml && \
  go get github.com/PuerkitoBio/purell && \
  go get github.com/PuerkitoBio/urlesc && \
  go get github.com/bep/gitmap && \
  go get github.com/bep/inflect && \
  go get github.com/cpuguy83/go-md2man/md2man && \
  go get github.com/davecgh/go-spew/spew && \
  go get github.com/dchest/cssmin && \
  go get github.com/eknkc/amber && \
  go get github.com/eknkc/amber/parser && \
  go get github.com/fortytw2/leaktest && \
  go get github.com/fsnotify/fsnotify && \
  go get github.com/gorilla/websocket && \
  go get github.com/hashicorp/hcl && \
  go get github.com/hashicorp/hcl/hcl/ast && \
  go get github.com/hashicorp/hcl/hcl/parser && \
  go get github.com/hashicorp/hcl/hcl/scanner && \
  go get github.com/hashicorp/hcl/hcl/strconv && \
  go get github.com/hashicorp/hcl/hcl/token && \
  go get github.com/hashicorp/hcl/json/parser && \
  go get github.com/hashicorp/hcl/json/scanner && \
  go get github.com/hashicorp/hcl/json/token && \
  go get github.com/inconshreveable/mousetrap && \
  go get github.com/kardianos/osext && \
  go get github.com/kr/fs && \
  go get github.com/kyokomi/emoji && \
  go get github.com/magiconair/properties && \
  go get github.com/miekg/mmark && \
  go get github.com/mitchellh/mapstructure && \
  go get github.com/nicksnyder/go-i18n/i18n/bundle && \
  go get github.com/nicksnyder/go-i18n/i18n/language && \
  go get github.com/nicksnyder/go-i18n/i18n/translation && \
  go get github.com/opennota/urlesc && \
  go get github.com/pelletier/go-buffruneio && \
  go get github.com/pelletier/go-toml && \
  go get github.com/pkg/errors && \
  go get github.com/pkg/sftp && \
  go get github.com/pmezard/go-difflib/difflib && \
  go get github.com/russross/blackfriday && \
  go get github.com/shurcooL/sanitized_anchor_name && \
  go get github.com/spf13/afero && \
  go get github.com/spf13/afero/mem && \
  go get github.com/spf13/cast && \
  go get github.com/spf13/cobra && \
  go get github.com/spf13/cobra/doc && \
  go get github.com/spf13/fsync && \
  go get github.com/spf13/jwalterweatherman && \
  go get github.com/spf13/nitro && \
  go get github.com/spf13/pflag && \
  go get github.com/spf13/viper && \
  go get github.com/stretchr/testify/assert && \
  go get github.com/stretchr/testify/require && \
  go get github.com/yosssi/ace && \
  go get golang.org/x/crypto/curve25519 && \
  go get golang.org/x/crypto/ed25519 && \
  go get golang.org/x/crypto/ed25519/internal/edwards25519 && \
  go get golang.org/x/crypto/ssh && \
  go get golang.org/x/net/idna && \
  go get golang.org/x/sys/unix && \
  go get golang.org/x/text/cases && \
  go get golang.org/x/text/internal && \
  go get golang.org/x/text/internal/tag && \
  go get golang.org/x/text/language && \
  go get golang.org/x/text/runes && \
  go get golang.org/x/text/secure/bidirule && \
  go get golang.org/x/text/secure/precis && \
  go get golang.org/x/text/transform && \
  go get golang.org/x/text/unicode/bidi && \
  go get golang.org/x/text/unicode/norm && \
  go get golang.org/x/text/width && \
  go get gopkg.in/yaml.v2 && \

  make && \
  mv hugo /opt/hugo/hugo && \
  cd /opt && \
  rm -rf gopath && \

  apk del go make

CMD ["/bin/bash", "/opt/container/script/run-hugo.sh"]
