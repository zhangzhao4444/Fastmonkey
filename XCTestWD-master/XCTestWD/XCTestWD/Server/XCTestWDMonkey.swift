//
//  XCTestWDMonkey.swift
//  XCTestWD
//
//  Created by zhangzhao on 2017/8/29.
//  Copyright © 2017年 FastMonkey. All rights reserved.


import Foundation

public class XCTestWDMonkey {
    public init() {
        
    }
    public func startMonkey() -> Int {
        let bundleID = "com.pandatv.test.meizi"
        // 把bundle ID改为被测试App的bundelID，然后把下面这行代码删除
        assertionFailure("change bundeID to your own target app")

        var app : XCUIApplication!
        var session : XCTestWDSession!
        let path :String? = nil
        app = XCUIApplication.init(privateWithPath: path, bundleID: bundleID)!
        app!.launch()

        if app != nil {
            session = XCTestWDSession.sessionWithApplication(app!)
            XCTestWDSessionManager.singleton.mountSession(session)
            session.resolve()
        }

        if app?.processID == 0 {
            return -1
        }

        sleep(4)
        NSLog("XCTestWDSetup->start fastmonkey<-XCTestWDSetup")

        _ = app.descendants(matching: .any).element(boundBy: 0).frame
        let monkey = Monkey(frame: app.frame)
        monkey.addDefaultXCTestPrivateActions()
        monkey.addXCTestTapAlertAction(interval: 100, application: app)
        monkey.addXCTestCheckCurrentApp(interval: 10, application: app)
        //monkey.addXCTestAppLogin(interval: 50, application: app)
        monkey.monkeyAround()
        RunLoop.main.run()
        return 0
    }

}
