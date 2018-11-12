//
//  XCTestWDFindElementUtils.swift
//  XCTestWD
//
//  fixed by zhangzhao on 8/1/17.
//

import Foundation

class XCTestWDFindElementUtils {
    
    // TODO: provide alert filter here
    
    static func tree(underElement:XCUIElement) throws -> [CGPoint]? {
        return underElement.pageSourceToPoint()
    }
    
    static func getAppName(underElement:XCUIElement) -> String{
        return underElement.rootName()
    }
    
    static func getAppPid() -> Int32{
        let application = XCTestWDSession.activeApplication()
        let pid = application?.processID
        if pid == nil{
            return 0
        }
        return pid!
    }
    
    static func filterElement(usingText:String, withvalue:String, underElement:XCUIElement) throws -> XCUIElement? {
        
        return try filterElements(usingText:usingText, withValue:withvalue, underElement:underElement, returnAfterFirstMatch:true)?.first
    }
    
    
    // Routing for xpath, class name, name, id
    static func filterElements(usingText:String, withValue:String, underElement:XCUIElement, returnAfterFirstMatch:Bool) throws -> [XCUIElement]? {
        
        let isSearchByIdentifier = (usingText == "name" || usingText == "id" || usingText == "accessibility id")
        
        if usingText == "xpath" {
            return underElement.descendantsMatchingXPathQuery(xpathQuery: withValue,
                                                              returnAfterFirstMatch: returnAfterFirstMatch)
        } else if usingText == "class name" {
            return underElement.descendantsMatchingClassName(className: withValue,
                                                             returnAfterFirstMatch: returnAfterFirstMatch)
        } else if isSearchByIdentifier {
            return underElement.descendantsMatchingIdentifier(accessibilityId: withValue,
                                                              returnAfterFirstMatch: returnAfterFirstMatch)
        }
        
        throw XCTestWDRoutingError.noSuchUsingMethod
    }
    
}
