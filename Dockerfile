ARG CRYSTAL_VERSION=1.3.2

FROM crystallang/crystal:$CRYSTAL_VERSION as crystal_base

ARG NODE_VERSION=14.19.1
ARG AMBER_VERSION=1.2.1

# -------------------
# package management
# -------------------
RUN apt-get update \
  &&  apt-get install -y --allow-change-held-packages \
  build-essential \
  libreadline-dev \
  libsqlite3-dev \
  libpq-dev \
  libmysqlclient-dev \
  libssl-dev \
  libyaml-dev \
  libpcre3-dev \
  libevent-dev \
  curl \
  locales \
  vim \
  cmake \
  gconf-service \
  glib-networking \
  fonts-liberation \
  libgtk-3-0 \
  libappindicator1 \
  libappindicator3-1 \
  graphviz \
  && locale-gen ja_JP.UTF-8 \
  && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc \
  && echo "set mouse-=a" >> /root/.vimrc \
  && localedef -f UTF-8 -i ja_JP ja_JP.utf8 \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# -------------------
# node.js
# -------------------
ENV PATH "/.nodenv/bin:/.nodenv/shims:$PATH"
ENV NODENV_ROOT "/.nodenv"

RUN git clone https://github.com/nodenv/nodenv.git /.nodenv

RUN mkdir -p "$(nodenv root)"/plugins

RUN git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build

RUN nodenv install $NODE_VERSION

RUN nodenv global $NODE_VERSION

RUN npm install -g yarn

RUN nodenv rehash

# -------------------
# amber
# -------------------
RUN cd /tmp \
 && curl -L https://github.com/amberframework/amber/archive/refs/tags/v$AMBER_VERSION.tar.gz | tar xz \
 && ls -l \
 && cd amber-$AMBER_VERSION \
 && shards install \
 && make install

WORKDIR /app
