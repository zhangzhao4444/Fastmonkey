//
//  testUITests.swift
//  testUITests
//
//  fixed by zhangzhao on 29/08/2017.
//

import XCTest
import Swifter


class XCTextWDRunner: XCTestCase {
    var serverMode = false
    var server: XCTestWDServer?
    var monkey: XCTestWDMonkey?
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(terminate(notification:)),
                                               name: NSNotification.Name(rawValue: XCTestWDSessionShutDown),
                                               object: nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRunner() {
        if serverMode {
            self.server = XCTestWDServer()
            self.server?.startServer()
        }else{
            self.monkey = XCTestWDMonkey()
            _ = self.monkey?.startMonkey()
        }
    }
    
    @objc func terminate(notification: NSNotification){
        if serverMode {
            self.server?.stopServer()
        }
        NSLog("XCTestWDTearDown->Session Reset")
        assert(false, "")
    }
}
