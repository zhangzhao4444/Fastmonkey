//
//  XCTestWDTitleControllerTests.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 2/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDTitleControllerTests: XCTestWDUnitTestBase {

    func testTitleRetrieve() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDTitleController.title(request: request)
        let contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))
    }

}
