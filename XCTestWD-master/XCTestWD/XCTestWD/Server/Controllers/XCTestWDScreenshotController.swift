//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter
import SwiftyJSON

internal class XCTestWDScreenshotController: Controller {
  
  //MARK: Controller - Protocol
  static func routes() -> [(RequestRoute, RoutingCall)] {
    return [(RequestRoute("/wd/hub/screenshot", "get"), getScreenshot),
            (RequestRoute("/wd/hub/session/:sessionId/screenshot", "get"), getScreenshot)]
  }
  
  static func shouldRegisterAutomatically() -> Bool {
    return false
  }
  
  //MARK: Routing Logic Specification
  internal static func getScreenshot(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
    var base64String:String!
    let xcScreen:AnyClass? = NSClassFromString("XCUIScreen")
    if xcScreen != nil {
        let data = xcScreen?.value(forKeyPath: "mainScreen.screenshot.PNGRepresentation") as? NSData
        base64String = ((data?.base64EncodedString()))!
    } else {
        let data = (XCAXClient_iOS.sharedClient() as! XCAXClient_iOS).screenshotData()
        base64String = ((data?.base64EncodedString()))!
    }

    return XCTestWDResponse.response(session: request.session, value: JSON(base64String!))
  }

}
