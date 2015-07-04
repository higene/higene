#!/bin/bash
set -e

initialize() {
  mkdir -p /etc/nginx/sites-enabled
  cp -f /mnt/src/nginx.conf /opt/nginx/conf/nginx.conf
  cp -f /mnt/src/higene_nginx.conf /etc/nginx/sites-enabled/higene_nginx.conf

  git clone -b "${GIT_BRANCH}" https://github.com/jlhg/higene.git /opt/higene
  cd /opt/higene
  cp -f /mnt/src/database.yml config/database.yml
  cp -f /mnt/src/cequel.yml config/cequel.yml

  bundle install
  bin/rake tmp:create
  bin/rake tmp:clear
  bin/rake db:create
  bin/rake db:migrate
  bin/rake db:seed
  bin/rake cequel:keyspace:create
  bin/rake cequel:migrate
  bin/rake assets:precompile
  mkdir -p tmp
  chmod 777 -R tmp
  echo "export SECRET_KEY_BASE=$(bin/rake secret)" >> ~/.bash_profile
  . ~/.bash_profile
}

if test ! -d /opt/higene; then
  initialize
fi

test -f ~/.bash_profile && . ~/.bash_profile
/opt/nginx/sbin/nginx
