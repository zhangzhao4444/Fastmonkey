//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter
import XCTest
import SwiftyJSON
import CocoaLumberjackSwift

let XCTestWDSessionShutDown = "XCTestWDSessionShutDown"

internal class XCTestWDSessionController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/session", "post"), createSession),
                (RequestRoute("/wd/hub/sessions", "get"), getSessions),
                (RequestRoute("/wd/hub/session/:sessionId", "delete"), delSession)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func createSession(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        var app : XCUIApplication!
        var session : XCTestWDSession!
        
        let desiredCapabilities = request.jsonBody["desiredCapabilities"].dictionary
        let path = desiredCapabilities?["app"]?.string ?? nil
        let bundleID = desiredCapabilities?["bundleId"]?.string ?? nil
        
        if bundleID == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) bundle ID input is nil, create session with current active app")
            app = XCTestWDSession.activeApplication()
        } else {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) create bundle from launching input")
            app = XCUIApplication.init(privateWithPath: path, bundleID: bundleID)!
            app!.launchArguments = desiredCapabilities?["arguments"]?.arrayObject as! [String]? ?? [String]()
            app!.launchEnvironment = desiredCapabilities?["environment"]?.dictionaryObject as! [String : String]? ?? [String:String]();
            app!.launch()
            sleep(1)
        }
        
        if app != nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) create app failure ")
            session = XCTestWDSession.sessionWithApplication(app!)
            XCTestWDSessionManager.singleton.defaultSession = session;
            XCTestWDSessionManager.singleton.mountSession(session)
            session.resolve()
        }
        
        if app?.processID == 0 {
            return HttpResponse.internalServerError
        }
        
        return XCTestWDResponse.response(session: session, value: sessionInformation(session))
    }
    
    internal static func getSessions(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return XCTestWDResponse.response(session: nil, value: sessionList())
    }
    
    internal static func delSession(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return XCTestWDResponse.response(session: nil, value: removeSessionById(request.session?.identifier ?? ""))
    }
    
    //MARK: Response helpers
    private static func sessionInformation(_ session:XCTestWDSession) -> JSON {
        var result:JSON = ["sessionId":session.identifier]
        var capabilities:JSON = ["device": UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? "ipad" : "iphone"]
        capabilities["sdkVersion"] = JSON(UIDevice.current.systemVersion)
        capabilities["browserName"] = JSON(session.application.label)
        capabilities["CFBundleIdentifier"] = JSON(session.application.bundleID ?? "Null")
        result["capabilities"] = capabilities
        return result
    }
    
    private static func sessionList() -> JSON {
        var raw = [[String:String]]()
        let sessionMap = XCTestWDSessionManager.singleton.queryAll()
        for (sessionId, _) in sessionMap {
            raw.append(["id":sessionId])
        }
        return JSON(raw)
    }
    
    private static func removeSessionById(_ sessionId:String) -> JSON {
        XCTestWDSessionManager.singleton.deleteSession(sessionId)
        return JSON("")
    }
}
