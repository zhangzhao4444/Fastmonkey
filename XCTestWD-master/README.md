# XCTestWD

[![NPM version][npm-image]][npm-url]
[![build status][travis-image]][travis-url]
[![Test coverage][coveralls-image]][coveralls-url]
[![node version][node-image]][node-url]
[![npm download][download-image]][download-url]

[npm-image]: https://img.shields.io/npm/v/xctestwd.svg?style=flat-square
[npm-url]: https://npmjs.org/package/xctestwd
[travis-image]: https://img.shields.io/travis/macacajs/XCTestWD.svg?style=flat-square
[travis-url]: https://travis-ci.org/macacajs/XCTestWD
[coveralls-image]: https://img.shields.io/coveralls/macacajs/XCTestWD.svg?style=flat-square
[coveralls-url]: https://coveralls.io/r/macacajs/XCTestWD?branch=master
[node-image]: https://img.shields.io/badge/node.js-%3E=_6-green.svg?style=flat-square
[node-url]: http://nodejs.org/download/
[download-image]: https://img.shields.io/npm/dm/xctestwd.svg?style=flat-square
[download-url]: https://npmjs.org/package/xctestwd

> A Swift implementation of WebDriver server for iOS that runs on Simulator/iOS devices. 

## 1. Requirements

- XCode version 8.3.0 and above.
- iOS version 9.0 and above.

## 2. Starting XCTestWD

XCTestWD can be either started with XCode IDE or via simple xcodebuild command line. By default, the webdriver agent occupies port `8001`.  You can override the default port in XCode by searching `XCTESTWD_PORT` under project build settings. Alternatively, it can also be overrided when you execute command line method as specified in `2.2. Using Xcodebuild`

### 2.1. Using Xcode

Download the project and open the XCode project, checkout the scheme `XCTestWDUITests` and run the test case `XCTextWDRunner`

### 2.2. Using XcodeBuild

Open the terminal, go to the directory where contains `XCTestWD.xcodeproj` file and execute the following command:

``` bash
#
#Change the port number to override the default port 
#
$ xcodebuild -project XCTestWD.xcodeproj \
           -scheme XCTestWDUITests \
           -destination 'platform=iOS Simulator,name=iPhone 6' \
           XCTESTWD_PORT=8001 \
           clean test
```

To execute for iOS device, run the following command:

``` bash
#
#Change the port number to override the default port 
#Specify the device name
#
$ xcodebuild -project XCTestWD.xcodeproj \
           -scheme XCTestWDUITests \
           -destination 'platform=iOS,name=(your device name)' \
           XCTESTWD_PORT=8001 \
           clean test
```


## 3. Element Types

In the current protocol, element strings for each `XCUIElementType` are generated based on the existing mapping in [reference/xctest/xcuielementtype](https://developer.apple.com/reference/xctest/xcuielementtype)
