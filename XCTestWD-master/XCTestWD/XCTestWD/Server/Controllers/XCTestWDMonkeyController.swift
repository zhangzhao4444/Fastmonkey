//
//  XCTestWDMonkeyController.swift
//  FastMonkey
//
//  Created by zhangzhao on 2017/7/17.
//  Copyright © 2017年 FastMonkey. All rights reserved.
//

import Foundation
import Swifter
import XCTest
import SwiftyJSON


internal class XCTestWDMonkeyController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/monkey", "post"), swiftmonkey),
                (RequestRoute("/wd/hub/appname", "get"), getappname)
        ]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    internal static func getappname(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        let name = XCTestWDFindElementUtils.getAppName(underElement: application!)
        return HttpResponse.ok(.html(name))
    }
    
    
    //MARK: Routing Logic Specification
    internal static func swiftmonkey(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        var app : XCUIApplication!
        var session : XCTestWDSession!
        
        let desiredCapabilities = request.jsonBody["desiredCapabilities"].dictionary
        let path = desiredCapabilities?["app"]?.string ?? nil
        let bundleID = desiredCapabilities?["bundleId"]?.string ?? nil
        if bundleID == nil {
            app = XCTestWDSession.activeApplication()
        } else {
            app = XCUIApplication.init(privateWithPath: path, bundleID: bundleID)!
            app!.launchArguments = desiredCapabilities?["arguments"]?.arrayObject as! [String]? ?? [String]()
            app!.launchEnvironment = desiredCapabilities?["environment"]?.dictionaryObject as! [String : String]? ?? [String:String]();
            app!.launch()
        }
        
        if app != nil {
            session = XCTestWDSession.sessionWithApplication(app!)
            XCTestWDSessionManager.singleton.mountSession(session)
            try? session.resolve()
        }
        
        if app?.processID == 0 {
            return HttpResponse.internalServerError
        }
        
        sleep(10)
        NSLog("XCTestWDSetup->start fastmonkey<-XCTestWDSetup")
        
        _ = app.descendants(matching: .any).element(boundBy: 0).frame
        let monkey = Monkey(frame: app.frame)
        monkey.addDefaultXCTestPrivateActions()
        monkey.addXCTestTapAlertAction(interval: 100, application: app)
        monkey.addXCTestCheckCurrentApp(interval: 10, application: app)
        //monkey.addXCTestAppLogin(interval: 50, application: app)
        monkey.monkeyAround()
        
        return XCTestWDResponse.response(session: session, value: sessionInformation(session))
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
    
}
