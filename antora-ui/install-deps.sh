#!/usr/bin/env bash

export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

nvm use 8
yarn install

npm install gulp