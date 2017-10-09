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

internal class XCTestWDElementController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/wd/hub/session/:sessionId/element", "post"), findElement),
                (RequestRoute("/wd/hub/session/:sessionId/elements", "post"), findElements),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/element", "post"), findElement),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/elements", "post"), findElements),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/value", "post"), setValue),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/click", "post"), click),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/text", "get"), getText),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/clear", "post"), clearText),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/displayed", "get"), isDisplayed),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/attribute/:name", "get"), getAttribute),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/property/:name", "get"), getAttribute),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/css/:propertyName", "get"), getComputedCss),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/rect", "get"), getRect),
                (RequestRoute("/wd/hub/session/:sessionId/tap/:elementId", "post"), tap),
                (RequestRoute("/wd/hub/session/:sessionId/doubleTap", "post"), doubleTapAtCoordinate),
                (RequestRoute("/wd/hub/session/:sessionId/keys", "post"), handleKeys),
                (RequestRoute("/wd/hub/session/:sessionId/title", "get"), title),
                (RequestRoute("/wd/hub/session/:sessionId/homeScreen", "post"), homeScreen),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/doubleTap", "post"), doubleTap),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/touchAndHold", "post"), touchAndHoldOnElement),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/twoFingerTap", "post"), handleTwoElementTap),
                (RequestRoute("/wd/hub/session/:sessionId/touchAndHold", "post"), touchAndHold),
                (RequestRoute("/wd/hub/session/:sessionId/dragfromtoforduration", "post"), dragForDuration),
                (RequestRoute("/wd/hub/session/:sessionId/element/:elementId/pinch", "post"), pinch)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func findElement(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.jsonBody["using"].string
        let value = request.jsonBody["value"].string
        let uuid  = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = session.cache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let element = try? XCTestWDFindElementUtils.filterElement(usingText: usage!, withvalue: value!, underElement: application!)
        
        if let element = element {
            if let element = element {
                return XCTestWDResponse.responseWithCacheElement(element, session.cache)
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func findElements(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.jsonBody["using"].string
        let value = request.jsonBody["value"].string
        let uuid  = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = session.cache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let elements = try? XCTestWDFindElementUtils.filterElements(usingText: usage!, withValue: value!, underElement: root!, returnAfterFirstMatch: false)
        
        if let elements = elements {
            if let elements = elements {
                return XCTestWDResponse.responsWithCacheElements(elements, session.cache)
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func setValue(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let value = request.jsonBody["value"][0].string
        
        if value == nil || elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.elementType == XCUIElementType.pickerWheel {
            element?.adjust(toPickerWheelValue: value!)
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        if element?.elementType == XCUIElementType.slider {
            element?.adjust(toNormalizedSliderPosition: CGFloat((value! as NSString).floatValue))
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        if element?.hasKeyboardFocus != true {
            element?.tap()
        }
        if element?.hasKeyboardFocus == true {
            element?.typeText(value!)
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
    }
    
    internal static func click(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if (element?.exists)! && (element?.isHittable)! {
            element?.tap()
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func getText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        let text:String = firstNonEmptyValue(element?.wdValue() as? String, element?.wdLabel()) ?? ""
        return XCTestWDResponse.response(session: session, value: JSON(text))
    }
    
    internal static func clearText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.hasKeyboardFocus != true {
            element?.tap()
        }
        if element?.hasKeyboardFocus == true {
            let text:String = firstNonEmptyValue(element?.wdValue() as? String, element?.wdLabel()) ?? ""
            let len = text.characters.count
            var bom = "\u{8}"
            var typeString = ""
            for _ in 1...len {
                typeString=typeString + bom
            }
            element?.typeText(typeString)
            //element?.typeText("")
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
    }
    
    internal static func isDisplayed(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.lastSnapshot == nil {
            element?.resolve()
        }
        let isW = try? element?.lastSnapshot.isWDVisible()
        return XCTestWDResponse.response(session: session, value: JSON(isW as Any))
    }
    
    internal static func getAttribute(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let attributeName = request.params[":name"]
        
        if elementId == nil || attributeName == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        let value = element?.value(forKey: (attributeName?.capitalized)!)
        return XCTestWDResponse.response(session: session, value: JSON(value as Any))
    }
    
    internal static func getRect(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        return XCTestWDResponse.response(session: session, value: JSON(element?.wdRect() as Any))
    }
    
    internal static func tap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let elementId = request.params[":elementId"]
        let element = session.cache.elementForUUID(elementId)
        
        if element != nil {
            element?.tap()
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            let rawX = getFloatValue(target: request.jsonBody, field: "x")
            let rawY = getFloatValue(target: request.jsonBody, field: "y")
            
            if rawX == nil || rawY == nil {
                return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
            }
            
            let x = CGFloat(rawX!)
            let y = CGFloat(rawY!)
            
            let coordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
            let triggerCoordinate = XCUICoordinate.init(coordinate: coordinate, pointsOffset: CGVector.init(dx: x, dy: y))
            triggerCoordinate?.tap()
            
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
    }
    
    internal static func doubleTapAtCoordinate(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        
        let rawX = getFloatValue(target: request.jsonBody, field: "x")
        let rawY = getFloatValue(target: request.jsonBody, field: "y")
        
        if rawX == nil || rawY == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let x = CGFloat(rawX!)
        let y = CGFloat(rawY!)
        
        let coordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
        let triggerCoordinate = XCUICoordinate.init(coordinate: coordinate, pointsOffset: CGVector.init(dx: x, dy: y))
        triggerCoordinate?.doubleTap()
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func touchAndHold(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let action = request.jsonBody
        
        let rawX = getFloatValue(target: request.jsonBody, field: "x")
        let rawY = getFloatValue(target: request.jsonBody, field: "y")
        
        if rawX == nil || rawY == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let x = CGFloat(rawX!)
        let y = CGFloat(rawY!)
        let duration = getDoubleValue(target: action, field: "duration")
        
        let coordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
        let triggerCoordinate = XCUICoordinate.init(coordinate: coordinate, pointsOffset: CGVector.init(dx: x, dy: y))
        triggerCoordinate?.press(forDuration: duration ?? 1)
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func touchAndHoldOnElement(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let action = request.jsonBody
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let duration = getDoubleValue(target: action, field: "duration")
        
        element?.press(forDuration: duration ?? 2)
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    
    internal static func dragForDuration(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let action = request.jsonBody
        
        let rawX = getFloatValue(target: action, field: "fromX")
        let rawY = getFloatValue(target: action, field: "fromY")
        let rawToX = getFloatValue(target: action, field: "toX")
        let rawToY = getFloatValue(target: action, field: "toY")
        
        
        if rawX == nil || rawY == nil || rawToX == nil || rawToY == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let x = CGFloat(rawX!)
        let y = CGFloat(rawY!)
        let toX = CGFloat(rawToX!)
        let toY = CGFloat(rawToY!)
        let duration = getDoubleValue(target: action, field: "duration")
        
        let coordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
        let triggerCoordinate = XCUICoordinate.init(coordinate: coordinate, pointsOffset: CGVector.init(dx: x, dy: y))
        
        let endCoordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
        let endTriggerCoordinate = XCUICoordinate.init(coordinate: endCoordinate, pointsOffset: CGVector.init(dx: toX, dy: toY))
        
        triggerCoordinate?.press(forDuration: duration ?? 1, thenDragTo: endTriggerCoordinate!)
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func pinch(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let action = request.jsonBody
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let scale = CGFloat(getDoubleValue(target: action, field: "scale") ?? 2)
        let velocity = CGFloat(getDoubleValue(target: action, field: "velocity") ?? 1)
        
        element?.pinch(withScale: scale, velocity: velocity)
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func handleTwoElementTap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        element?.twoFingerTap()
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func handleKeys(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let action = request.jsonBody
        let text = action["value"][0].string ?? ""
        
        XCTestDaemonsProxy.testRunnerProxy()._XCT_send(text, maximumFrequency: 60) { (error) in
            if error != nil {
                print("Error occured in sending key: \(error.debugDescription)")
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func homeScreen(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        XCUIDevice.shared().press(XCUIDeviceButton.home)
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func title(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = session.application
        let elements = application?.descendants(matching: XCUIElementType.window).allElementsBoundByIndex
        
        if  elements == nil || elements?.count == 0 {
            return XCTestWDResponse.response(session: nil, error: WDStatus.ElementNotVisible)
        }
        
        let window = elements![0]
        let navBar = window.descendants(matching: XCUIElementType.navigationBar).allElementsBoundByIndex.first
        
        if (navBar?.identifier.characters.count) ?? 0 > 0 {
            return XCTestWDResponse.response(session: nil, value: JSON(navBar?.identifier as Any))
        } else {
            window.resolve()
            let digest = window.digest()
            //NSLog("XCTestWDSetup->title\(digest)<-XCTestWDSetup")
            return XCTestWDResponse.response(session: nil, value: JSON(digest as Any))
        }
    }
    

    internal static func doubleTap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if element != nil {
            element?.doubleTap()
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            let rawX = getFloatValue(target: request.jsonBody, field: "x")
            let rawY = getFloatValue(target: request.jsonBody, field: "y")
            
            if rawX == nil || rawY == nil {
                return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
            }
            
            let x = CGFloat(rawX!)
            let y = CGFloat(rawY!)
            
            let coordinate = XCUICoordinate.init(element: session.application, normalizedOffset: CGVector.init())
            let triggerCoordinate = XCUICoordinate.init(coordinate: coordinate, pointsOffset: CGVector.init(dx: x, dy: y))
            triggerCoordinate?.doubleTap()
            
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
    }
    
    //MARK: WEB impl methods
    internal static func getProperty(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getProperty"))
    }
    
    internal static func getComputedCss(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getComputedCss"))
    }
    
    private static func getFloatValue(target:JSON?, field:String) -> Float? {
        if target == nil {
            return nil
        }
        
        if target![field].type == Type.string {
            return Float.init((target![field].rawString()) ?? "")
        } else if target![field].type == Type.number {
            return target![field].float
        }
        
        return nil
    }
    
    private static func getDoubleValue(target:JSON?, field:String) -> Double? {
        if target == nil {
            return nil
        }
        
        if target![field].type == Type.string {
            return Double.init((target![field].rawString()) ?? "")
        } else if target![field].type == Type.number {
            return target![field].double
        }
        
        return nil
    }
}
