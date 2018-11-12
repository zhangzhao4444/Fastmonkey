
//
//  XCTestWDUnitTestBase.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 1/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import SwiftyJSON
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDUnitTestBase: XCTestCase {

    var springApplication: XCUIApplication?

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCTestWDSessionManager.singleton.clearAll()
        self.springApplication = XCTestWDApplication.activeApplication()
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(2)
    }
    
    override func tearDown() {
        super.tearDown()
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        XCTestWDSessionManager.singleton.clearAll()
    }

    static func getResponseData(_ response: Swifter.HttpResponse) -> JSON {
        switch response {
        case .ok(let body):
            switch body {
            case .text(let content):
                if let dataFromString = content.data(using: .utf8, allowLossyConversion: false) {
                    return (try? JSON(data: dataFromString)) ?? JSON.init(stringLiteral: "")
                } else {
                    break
                }
            case .html( _):
                return JSON(["status": 0])
            default:
                break
            }
        default:
           break
        }

        return JSON.init("")
    }
}

extension HttpResponse {
    func shouldBeSuccessful()
    {
        let jsonContent = XCTestWDUnitTestBase.getResponseData(self)
        expect(jsonContent["status"]).to(equal(0))
        expect(self.statusCode()).to(equal(200))
    }
}

