//
//  XCTestWDScreenShotControllerTest.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 6/5/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDScreenShotControllerTest: XCTestWDUnitTestBase {

    func testScreenShotRetrieve() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDScreenshotController.getScreenshot(request: request)
        let contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))
    }

}
