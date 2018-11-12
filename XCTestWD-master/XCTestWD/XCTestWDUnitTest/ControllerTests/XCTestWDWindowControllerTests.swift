
//
//  XCTestWDWindowControllerTests.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 2/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDWindowControllerTests: XCTestWDUnitTestBase {

    func testWindowSize() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDWindowController.getWindowSize(request: request)
        response.shouldBeSuccessful()
    }
    
}
