#!/bin/bash

# Install pre-required packages
sed -i.orig 's/\/archive.ubuntu.com\//\/tw.archive.ubuntu.com\//' /etc/apt/sources.list
apt-get -y update
apt-get -y install autoconf bison build-essential \
        libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
        libncurses5-dev libffi-dev libgdbm3 libgdbm-dev \
        libsqlite3-dev libcurl4-openssl-dev libpq-dev \
        nodejs curl git
apt-get clean

# Install Ruby
curl http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz | tar zx
cd ruby-2.1.5
./configure
make install
cd ..
rm -rf ruby-2.1.5
gem update --system

# Install passenger and nginx
gem install passenger -v 5.0.10
gem install bundler -v 1.10.3
passenger-install-nginx-module --auto-download \
                               --languages ruby \
                               --auto
