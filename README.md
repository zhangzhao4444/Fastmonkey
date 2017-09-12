# FastMonkey 

> A Swift implementation of Monkey TEST(Non-Stub) for iOS that runs on Simulator/iOS devices. 

1.0.0.1002 支持
1. 非插桩monkey点击事件
2. app后台或退出检测
3. 基于控件点击事件
4. 自定义业务序列事件


- homepage :  https://testerhome.com/topics/9524

## 1. Requirements

- XCode version 8.3.0 and above.
- iOS version 9.0 and above.

## 2. Starting 

FastMonkey can be either started with XCode IDE or via simple xcodebuild command line. 

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

To execute Monkey for iOS device, run the following command:

``` bash
#
#Change the port number to override the default port 
#Specify the device name
#
$ iproxy 8001 8001

$ xcodebuild -project XCTestWD.xcodeproj -scheme XCTestWDUITests -destination 'platform=iOS,name=(your device name)' XCTESTWD_PORT=8001 clean test
#
# Now server is started and listening in 8001
# To start Monkey run:

$curl -X POST -H "Content-Type:application/json" -d "{\"desiredCapabilities\":{\"deviceName\":\"xxxx\",\"platformName\":\"iOS\", \"bundleId\":\"com.PandaTV.Live-iPhone\",\"autoAcceptAlerts\":\"false\"}}"  http://127.0.0.1:8001/wd/hub/monkey


```
