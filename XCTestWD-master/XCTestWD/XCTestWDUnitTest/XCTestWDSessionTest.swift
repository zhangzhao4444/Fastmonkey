//
//  XCTestWDUnitTest.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 31/3/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Swifter
import Nimble
@testable import XCTestWD

class XCTestWDSessionTest: XCTestWDUnitTestBase {

    func testApplicationLaunch() {
        XCTAssert(self.springApplication != nil, "application should not be nil")
    }

    func testFetchSystemApplicaiton() {
        let systemApplication = (XCAXClient_iOS.sharedClient() as! XCAXClient_iOS).systemApplication()
        let springBoardApplication = XCTestWDApplication.create(byPID: pid_t(((systemApplication as! NSObject).value(forKey: "processIdentifier") as! NSNumber).intValue))

        XCTAssert(springBoardApplication != nil, "application should not be nil")
    }
    
    func testSessionCreation() {
        XCTAssert(self.springApplication?.bundleID == XCTestWDSession.activeApplication()?.bundleID)
        
        let session = XCTestWDSession.sessionWithApplication(self.springApplication!)
        XCTestWDSessionManager.singleton.mountSession(session)
        
        XCTAssert(XCTestWDSessionManager.singleton.queryAll().keys.count == 1, "key length should be one, containing");
    }
    
    func testSessionDeletion() {
        self.testSessionCreation()
        
        XCTestWDSessionManager.singleton.clearAll();
        
        XCTAssert(XCTestWDSessionManager.singleton.queryAll().keys.count == 0, "key length shoud be zero")
    }
    
    func testSessionIDDeletion() {
        let session = XCTestWDSession.sessionWithApplication(self.springApplication!)
        XCTestWDSessionManager.singleton.mountSession(session)

        XCTAssert(XCTestWDSessionManager.singleton.queryAll().keys.count == 1, "key length should be one, containing");

        XCTestWDSessionManager.singleton.deleteSession(session.identifier)
        XCTAssert(XCTestWDSessionManager.singleton.queryAll().keys.count == 0, "key length shoud be zero")
    }
    
    func testElementCache() {
        let uuid = XCTestWDSessionManager.commonCache.storeElement(self.springApplication!)
        expect(XCTestWDSessionManager.commonCache.elementForUUID(uuid)).to(equal(self.springApplication!))
    }
}
