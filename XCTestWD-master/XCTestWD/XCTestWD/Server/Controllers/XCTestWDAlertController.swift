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
import CocoaLumberjackSwift

internal class XCTestWDAlertController: Controller {
  
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/session/:sessionId/accept_alert", "post"), acceptAlert),
                (RequestRoute("/wd/hub/session/:sessionId/dismiss_alert", "post"), dismissAlert),
                (RequestRoute("/wd/hub/session/:sessionId/alert_text", "get"), alertText),
                (RequestRoute("/wd/hub/session/:sessionId/alert_text", "post"), alertKeys)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func acceptAlert(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        if request.session == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.SessionNotCreatedException)
        } else {
            let alert = XCTestWDAlert(request.session!.application)
            if alert.accept() {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) accepAlert success")
                return XCTestWDResponse.response(session: request.session!, value: nil)
            } else {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) accepAlert failure")
                return XCTestWDResponse.response(session: request.session!, error: WDStatus.NoAlertOpenError)
            }
        }
    }
    
    internal static func dismissAlert(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        if request.session == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.SessionNotCreatedException)
        } else {
            let alert = XCTestWDAlert(request.session!.application)
            if alert.dismiss() {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) dismissAlert success")
                return XCTestWDResponse.response(session: request.session!, value: nil)
            } else {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) dismissAlert failure")
                return XCTestWDResponse.response(session: request.session!, error: WDStatus.NoAlertOpenError)
            }
        }
    }
    
    internal static func alertText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        if request.session == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.SessionNotCreatedException)
        } else {
            let alert = XCTestWDAlert(request.session!.application)
            let text = alert.text()
            if text != nil {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) retrieving alert text \(text!)")
                return XCTestWDResponse.response(session: request.session!, value: JSON(text!))
            } else {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) retrieving alert text nil")
                return XCTestWDResponse.response(session: request.session!, error: WDStatus.NoAlertOpenError)
            }
        }
    }
    
    internal static func alertKeys(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        if request.session == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.SessionNotCreatedException)
        } else {
            let alert = XCTestWDAlert(request.session!.application)
            if alert.keys(input: request.params["text"] ?? "") {
                return XCTestWDResponse.response(session: request.session!, value: JSON(text!))
            } else {
                return XCTestWDResponse.response(session: request.session!, error: WDStatus.NoAlertOpenError)
            }
        }
    }
  
}
