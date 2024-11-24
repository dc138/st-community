#!/usr/bin/env bash

cd "$(dirname "$0")"
source ./version

date=$(date '+%Y%m%d')

echo "==> getting sources"

if [ ! -d 'st' ] || [ ! -d 'st/.git' ]; then
  rm -rfv 'st'
  git clone git://git.suckless.org/st st
  cd 'st'
  git checkout $rev

else
  cd 'st'
  git reset --hard origin/master
  git checkout master
  git clean -xdf
  git pull
  git checkout $rev
fi

echo "==> applying patches"

for f in ../patches/*.diff; do
  if ! patch -p1 --no-backup-if-mismatch < $f; then
    echo "=> failed to apply patch $(basename $f), aborting..."
    exit
  else
    echo "=> correctly applied patch $(basename $f)"
  fi
done

echo "==> generaing unified patch file"

rm -f ../st-community-*-*.diff

git add .
git commit -m 'st-community: apply patches'
git format-patch 'HEAD^' --stdout > "../st-community-$date-$rev.diff"
