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

enum OperationError:Error{
    case Error
}


internal class XCTestWDSession {
    
    var identifier: String!
    var cache: XCTestWDElementCache = XCTestWDElementCache()
    private var _application: XCUIApplication!
    var application: XCUIApplication! {
        get {
            // Add protection for application resolve. only when application status active cam execute this
            if _application.accessibilityActivate() == true {
                try? resolve()
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
        //var activeApplicationElement:XCAccessibilityElement?

        //activeApplicationElement = (XCAXClient_iOS.sharedClient() as! XCAXClient_iOS).activeApplications().first
        //if activeApplicationElement == nil {
        //    activeApplicationElement = (XCAXClient_iOS.sharedClient() as! XCAXClient_iOS).systemApplication() as? XCAccessibilityElement
        //}
        //let application = XCUIApplication.app(withPID: (activeApplicationElement?.processIdentifier)!)
        //_ = application?.query()

        //return application
        return XCTestWDApplication.activeApplication()
    }
    
    func resolve() throws {
        self._application.query()
        let pid = self._application.processID
        let app = XCTestWDSession.activeApplication()
        let currentprocessID = app?.processID
        if pid != currentprocessID{
            throw OperationError.Error
        }
        
        self._application?.resolve()
        
    }
}

//MARK: Multi-Session Control
internal class XCTestWDSessionManager {
    
    static let singleton = XCTestWDSessionManager()
    
    private var sessionMapping = [String: XCTestWDSession]()
    private var defaultSession:XCTestWDSession?
    
    func mountSession(_ session: XCTestWDSession) {
        sessionMapping[session.identifier] = session
    }
    
    func querySession(_ identifier:String) -> XCTestWDSession? {
        return sessionMapping[identifier]
    }
    
    func checkDefaultSessionthrow() throws -> XCTestWDSession {
        //if self.defaultSession == nil || self.defaultSession?.application.accessibilityActivate() == false {
        if self.defaultSession == nil || self.defaultSession?.application.state != XCUIApplication.State.runningForeground{
            let application = XCTestWDSession.activeApplication()
            self.defaultSession = XCTestWDSession.sessionWithApplication(application!)
        }
        do{
            try self.defaultSession?.resolve()
        }catch{
            throw OperationError.Error
        }
        
        return self.defaultSession!
    }
    
    func checkDefaultSession() -> XCTestWDSession {
//        if self.defaultSession == nil || self.defaultSession?.application.accessibilityActivate() == false {
        if self.defaultSession == nil || self.defaultSession?.application.state != XCUIApplication.State.runningForeground{
            sleep(2)
            let application = XCTestWDSession.activeApplication()
            self.defaultSession = XCTestWDSession.sessionWithApplication(application!)
        }
        
        try? self.defaultSession?.resolve()
        return self.defaultSession!
    }
    
    func queryAll() -> [String:XCTestWDSession] {
        return sessionMapping
    }
    
    func clearAll() {
        sessionMapping.removeAll()
    }
    
    func deleteSession(_ sessionId:String) {
        sessionMapping[sessionId]?.application.terminate()
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
                    return nil
                }
                return XCTestWDSessionManager.singleton.querySession(components[index + 1])
            } else {
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
            
            return nil
        }
    }
    
    var jsonBody:JSON {
        get {
            return try? JSON(data: NSData(bytes: &self.body, length: self.body.count) as Data)
        }
    }
}
