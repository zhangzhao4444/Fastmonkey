//
//  testUITests.swift
//  testUITests
//
//  Created by xdf on 14/04/2017.
//  Copyright © 2017 xdf. All rights reserved.
//

import XCTest
import Swifter


class XCTextWDRunner: XCTestCase {
    var server: XCTestWDServer?
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
        self.server = XCTestWDServer()
        self.server?.startServer()
        
    }
    
    @objc func terminate(notification: NSNotification){
        self.server?.stopServer();
        NSLog("XCTestWDTearDown->Session Reset")
        assert(false, "")
    }
}
