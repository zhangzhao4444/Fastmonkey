//
//  XCTestWDReponse.swift
//  XCTestWD
//
//  Created by zhaoy on 24/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import SwiftyJSON
import Swifter

internal class XCTestWDResponse {
    
    //MARK: Model & Constructor
    private var sessionId:String!
    private var status:WDStatus!
    private var value:JSON?
    
    private init(_ sessionId:String, _ status:WDStatus, _ value:JSON?) {
        self.sessionId = sessionId
        self.status = status
        self.value = value ?? JSON("")
    }
    
    private func response() -> HttpResponse {
        let response : JSON = ["sessionId":self.sessionId,
                               "status":self.status.rawValue,
                               "value":self.value as Any]
        let rawString = response.rawString(options:[])?.replacingOccurrences(of: "\n", with: "")
        return rawString != nil ? HttpResponse.ok(.text(rawString!)) : HttpResponse.ok(.text("{}"))
    }
    
    //MARK: Utils
    static func response(session:XCTestWDSession?, value:JSON?) -> HttpResponse {
        return XCTestWDResponse(session?.identifier ?? "", WDStatus.Success, value ?? JSON("{}")).response()
    }
    
    static func response(session:XCTestWDSession? ,error:WDStatus) -> HttpResponse {
        return XCTestWDResponse(session?.identifier ?? "", error, nil).response()
    }
    
    //MARK: Element Response
    static func responseWithCacheElement(_ element:XCUIElement, _ elementCache:XCTestWDElementCache) -> HttpResponse {
        let elementUUID = elementCache.storeElement(element)
        return getResponseFromDictionary(dictionaryWithElement(element, elementUUID, false))
    }
    
    static func responsWithCacheElements(_ elements:[XCUIElement], _ elementCache:XCTestWDElementCache) -> HttpResponse {
        var response = [[String:String]]()
        for element in elements {
            let elementUUID = elementCache.storeElement(element)
            response.append(dictionaryWithElement(element, elementUUID, false))
        }
        return XCTestWDResponse.response(session: nil, value: JSON(response))
    }
    
    // ------------ Internal Method ---------
    private static func dictionaryWithElement(_ element:XCUIElement, _ elementUUID:String, _ compact:Bool) -> [String:String] {
        var dictionary = [String:String]();
        dictionary["ELEMENT"] = elementUUID
        
        if compact == false {
            dictionary["label"] = element.wdLabel()
            dictionary["type"] = element.wdType()
        }
        
        return dictionary
    }
    
    private static func getResponseFromDictionary(_ dictionary:[String:String]) -> HttpResponse {
        return XCTestWDResponse.response(session:nil, value:JSON(dictionary))
    }
    
}
