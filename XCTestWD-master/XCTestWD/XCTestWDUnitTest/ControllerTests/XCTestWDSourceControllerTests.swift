//
//  XCTestWDSourceControllerTests.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 6/5/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
import SwiftyJSON
@testable import XCTestWD
@testable import Swifter

class XCTestWDSourceControllerTests: XCTestWDUnitTestBase {

    func testSourceRetrieve() {
        let request = Swifter.HttpRequest.init()
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        XCTestWDSessionManager.singleton.mountSession(session)
        request.params["sessionId"] = session.identifier
        
        // case 1. test source in home panel, full amount of elements available.
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        var response = XCTestWDSourceController.source(request: request)
        var contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))

        // case 2. test source in web app.
        request.body = [UInt8]((try? JSON(["value":"//*[@name=\"Safari\"]","using":"xpath"]).rawData()) ?? Data())
        response = XCTestWDElementController.findElement(request: request)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))
        var jsonResponse = XCTestWDUnitTestBase.getResponseData(response)
        expect(jsonResponse["value"]["ELEMENT"]).toNot(beNil())

        // click and enter safari
        request.path = "/element/\(jsonResponse["value"]["ELEMENT"])"
        response = XCTestWDElementController.click(request: request)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))

        response = XCTestWDSourceController.sourceWithoutSession(request: request)
        contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))

        // case 3. test source in native app.
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        // sliding to first panel
        XCUIDevice.shared.press(XCUIDevice.Button.home)

        request.body = [UInt8]((try? JSON(["value":"//*[@name=\"Messages\"]","using":"xpath"]).rawData()) ?? Data())
        response = XCTestWDElementController.findElement(request: request)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))
        jsonResponse = XCTestWDUnitTestBase.getResponseData(response)
        expect(jsonResponse["value"]["ELEMENT"]).toNot(beNil())

        // click and enter safari
        request.path = "/element/\(jsonResponse["value"]["ELEMENT"])"
        response = XCTestWDElementController.click(request: request)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))

        response = XCTestWDSourceController.sourceWithoutSession(request: request)
        contentJSON = XCTestWDUnitTestBase.getResponseData(response)
        expect(contentJSON["status"].int).to(equal(WDStatus.Success.rawValue))
    }
}
