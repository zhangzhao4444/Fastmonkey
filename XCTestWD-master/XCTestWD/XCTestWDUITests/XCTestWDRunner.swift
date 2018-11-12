//
//  testUITests.swift
//  testUITests
//
//  Created by xdf on 14/04/2017.
//  Copyright © 2017 xdf. All rights reserved.
//

import XCTest
import Swifter
import XCTestWD

public class XCTextWDRunner: XCTestWDFailureProofTest {
    var server: XCTestWDServer?
    var monkey: XCTestWDMonkey?
    override public func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCTestWDSessionManager.singleton.clearAll()
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(2)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(terminate(notification:)),
                                               name: NSNotification.Name(rawValue: "XCTestWDSessionShutDown"),
                                               object: nil)
    }
    
    override public func tearDown() {
        super.tearDown()
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        XCTestWDSessionManager.singleton.clearAll()
    }
    
    func testRunner() {
        self.monkey = XCTestWDMonkey()
        _ = self.monkey?.startMonkey()

    }
    
//    func testMultipleApps() {
//
//        let settingsApp = XCUIApplication(bundleIdentifier: "com.bytedance.ee.microapp.demo")
//        settingsApp.launch()
//        sleep(5)
//        settingsApp.terminate()
//
//        print("lalalalalala:\(settingsApp.state)")
//
//    }

    @objc func terminate(notification: NSNotification) {
        self.server?.stopServer();
        NSLog("XCTestWDTearDown->Session Reset")
        assert(false, "")
    }
}
