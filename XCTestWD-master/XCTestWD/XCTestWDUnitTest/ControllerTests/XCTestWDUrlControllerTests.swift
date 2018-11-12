//
//  XCTestWDUrlController.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 2/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDUrlControllerTests: XCTestWDUnitTestBase {
    
    func testUrlController() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.url(request: request)
        response.shouldBeSuccessful()
    }

    func testGetUrlController() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.getUrl(request: request)
        response.shouldBeSuccessful()
    }

    func testForwardUrlController() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.forward(request: request)
        response.shouldBeSuccessful()
    }

    func testRefreshUrlController() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.refresh(request: request)
        response.shouldBeSuccessful()
    }

    func testBack() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.back(request: request)
        let contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.ElementIsNotSelectable.rawValue))
    }
}
