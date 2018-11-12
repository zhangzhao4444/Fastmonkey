//
//  XCTestWDSession.swift
//  XCTestWD
//
//  Created by zhaoy on 23/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import Swifter
import SwiftyJSON
import CocoaLumberjackSwift

//MARK: Session & Cache for XCUIElement
internal class XCTestWDElementCache
{
    
    private var cache = [String: XCUIElement]()
    
    // Returns UUID of the stored element
    func storeElement(_ element:XCUIElement) -> String {
        let uuid = UUID.init().uuidString
        cache[uuid] = element
        return uuid
    }
    
    // Returns cached element
    func elementForUUID(_ uuid:String?) -> XCUIElement? {
        if uuid == nil {
            return nil
        }
        return cache[uuid!]
    }
}

public class XCTestWDSession {
    
    var identifier: String!
    private var _application: XCUIApplication!
    var application: XCUIApplication! {
        get {
            // Add protection for application resolve. only when application status active cam execute this
            if _application.accessibilityActivate() == true {
                resolve()
            }
            return _application
        }
        set {
            _application = newValue
        }
    }
    
    static func sessionWithApplication(_ application: XCUIApplication) -> XCTestWDSession {
        
        let session = XCTestWDSession()
        session.application = application
        session.identifier = UUID.init().uuidString
        
        return session
    }
    
    static func activeApplication() -> XCUIApplication?
    {
        return XCTestWDApplication.activeApplication()
    }
    
    func resolve() {
        self._application.query()
        self._application.resolve()
    }
}

//MARK: Multi-Session Control
public class XCTestWDSessionManager {
    
    public static let singleton = XCTestWDSessionManager()
    static let commonCache: XCTestWDElementCache = XCTestWDElementCache()
    
    private var sessionMapping = [String: XCTestWDSession]()
    var defaultSession:XCTestWDSession?
    
    func mountSession(_ session: XCTestWDSession) {
        sessionMapping[session.identifier] = session
    }
    
    func querySession(_ identifier:String) -> XCTestWDSession? {
        return sessionMapping[identifier]
    }
    
    func checkDefaultSession() -> XCTestWDSession {
        if self.defaultSession == nil || self.defaultSession?.application.state != XCUIApplication.State.runningForeground {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) current application not active, reloading active application")
            sleep(3)
            let application = XCTestWDSession.activeApplication()
            self.defaultSession = XCTestWDSession.sessionWithApplication(application!)
            self.defaultSession?.resolve()
        }
        
        return self.defaultSession!
    }
    
    func queryAll() -> [String:XCTestWDSession] {
        return sessionMapping
    }
    
    public func clearAll() {
        sessionMapping.removeAll()
    }
    
    func deleteSession(_ sessionId:String) {
        sessionMapping.removeValue(forKey: sessionId)
        NotificationCenter.default.post(name: NSNotification.Name(XCTestWDSessionShutDown), object: nil)
    }
}

//MARK: Extension
extension HttpRequest {
    var session: XCTestWDSession? {
        get {
            if self.params["sessionId"] != nil && XCTestWDSessionManager.singleton.querySession(self.params["sessionId"]!) != nil {
                return XCTestWDSessionManager.singleton.querySession(self.params["sessionId"]!)
            } else if self.path.contains("/session/") {
                let components = self.path.components(separatedBy:"/")
                let index = components.index(of: "session")!
                if index >= components.count - 1 {
                    DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) session can't be at the last component in the whole path")
                    return nil
                }
                return XCTestWDSessionManager.singleton.querySession(components[index + 1])
            } else {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) no session id in current request")
                return nil
            }
        }
    }
    
    var elementId: String? {
        get {
            if self.path.contains("/element/") {
                let components = self.path.components(separatedBy:"/")
                let index = components.index(of: "element")!
                if index < components.count - 1 {
                    return components[index + 1]
                }
            }

            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) no element id retrieved from current query")
            return nil
        }
    }
    
    var jsonBody:JSON {
        get {
            return (try? JSON(data: NSData(bytes: &self.body, length: self.body.count) as Data)) ?? JSON(parseJSON: "{}")
        }
    }
}
