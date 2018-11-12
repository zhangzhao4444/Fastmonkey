#!/bin/bash

brew install nvm > /dev/null 2>&1
source $(brew --prefix nvm)/nvm.sh
nvm install 8

npm i macaca-scripts -g

export XCTESTWD_PATH=`pwd`"/XCTestWD/XCTestWD.xcodeproj"

echo process env XCTESTWD_PATH set to $XCTESTWD_PATH

macaca-scripts integration-test-ios
