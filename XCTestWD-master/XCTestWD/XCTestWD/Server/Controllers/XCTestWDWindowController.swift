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

internal class XCTestWDWindowController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/session/:sessionId/window/current/size", "get"), getWindowSize)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func getWindowSize(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let application = XCTestWDSessionManager.singleton.checkDefaultSession().application
        let frame = application?.wdFrame()
        let screenSize = MathUtils.adjustDimensionsForApplication(frame!.size, UIDeviceOrientation.init(rawValue:(application?.interfaceOrientation.rawValue)!)!)
        
        return XCTestWDResponse.response(session: nil, value: JSON(["width":screenSize.width,"height":screenSize.height]))
    }
    
}
