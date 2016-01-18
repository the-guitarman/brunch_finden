#!/bin/bash

source $NVM_DIR/nvm.sh
nvm use 0.11

SOURCE_DIR="$HOME/sites/bootstrap-3.3.0/less"
DESTINATION_DIR="$HOME/sites/brunch_finden/public/stylesheets"

lessc "$SOURCE_DIR/bootstrap.less" "$DESTINATION_DIR/bootstrap.css"
lessc -x --clean-css "$SOURCE_DIR/bootstrap.less" "$DESTINATION_DIR/bootstrap.min.css"
