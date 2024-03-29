#!/usr/bin/env bash

SERVER="sgc"

dir=`mktemp -d`
git clone https://github.com/szabodanika/microbin $dir

cd $dir
cross build --target=aarch64-unknown-linux-gnu --release

rsync -vh --progress \
	target/aarch64-unknown-linux-gnu/release/microbin \
	$SERVER:/tmp/

cmds="
sudo mv /tmp/microbin /home/microbin/
sudo chown microbin:microbin /home/microbin/microbin
sudo systemctl restart microbin.service
"

ssh -t $SERVER "$cmds"
cd -
