//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter

internal class XCTestWDUrlController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/session/:sessionId/url", "post"), url),
                (RequestRoute("/wd/hub/session/:sessionId/url", "get"), getUrl),
                (RequestRoute("/wd/hub/session/:sessionId/forward", "post"), forward),
                (RequestRoute("/wd/hub/session/:sessionId/back", "post"), back),
                (RequestRoute("/wd/hub/session/:sessionId/refresh", "post"), refresh)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func url(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("url"))
    }
    
    internal static func getUrl(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getUrl"))
    }
    
    internal static func forward(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("forward"))
    }
    
    internal static func back(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = session.application
        if ((application?.navigationBars.buttons.count) ?? 0 > 0) {
            application?.navigationBars.buttons.element(boundBy: 0).tap()
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
    }
    
    internal static func refresh(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("refresh"))
    }
    
}
