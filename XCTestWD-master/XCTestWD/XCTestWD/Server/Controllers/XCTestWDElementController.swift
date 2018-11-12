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
import XCTest
import CocoaLumberjackSwift

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
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = session.application
        session.resolve()
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = XCTestWDSessionManager.commonCache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) root/usage/root one of those params are null")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let element = try? XCTestWDFindElementUtils.filterElement(usingText: usage!, withvalue: value!, underElement: application!)
        
        if let element = element {
            if let element = element {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) element hit and return")
                return XCTestWDResponse.responseWithCacheElement(element, XCTestWDSessionManager.commonCache)
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func findElements(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.jsonBody["using"].string
        let value = request.jsonBody["value"].string
        let uuid  = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = session.application
        session.resolve()
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = XCTestWDSessionManager.commonCache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) root/usage/root one of those params are null")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let elements = try? XCTestWDFindElementUtils.filterElements(usingText: usage!, withValue: value!, underElement: root!, returnAfterFirstMatch: false)
        
        if let elements = elements {
            if let elements = elements {
                return XCTestWDResponse.responsWithCacheElements(elements, XCTestWDSessionManager.commonCache)
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func setValue(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        let value = request.jsonBody["value"][0].string
        
        if value == nil || elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }

        if element == nil {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) setValue, abort since no element found")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.elementType == XCUIElement.ElementType.picker {
            element?.adjust(toPickerWheelValue: value!)
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) setValue, set picker value \(value!)")
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        if element?.elementType == XCUIElement.ElementType.slider {
            element?.adjust(toNormalizedSliderPosition: CGFloat((value! as NSString).floatValue))
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) setValue, set slider value \(value!)")

            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        if element?.hasKeyboardFocus != true {
            element?.tap()
        }
        
        if element?.hasKeyboardFocus == true {
            element?.typeText(value!)
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) dismiss keyboard after setValue")
            dismissKeyboard()
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) dismiss keyboard while aborting setValue, element does not have focus")
            dismissKeyboard()
            return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
        }
    }
    
    internal static func click(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if elementId == nil {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) click, abort by invalid elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            DDLogError("\(XCTestWDDebugInfo.DebugLogPrefix) click, abort by no such element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if (element?.exists)! && ((element?.isHittable) ?? false) {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) click, based on element coordinate")
            element?.coordinate(withNormalizedOffset: CGVector.init(dx: 0.5, dy: 0.5)).tap()
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func getText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if elementId == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getText, abort due to no elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getText, abort due to can't find element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        let text:String = firstNonEmptyValue(element?.wdValue() as? String, element?.wdLabel()) ?? ""
        return XCTestWDResponse.response(session: session, value: JSON(text))
    }
    
    internal static func clearText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if elementId == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) clearText, abort due to no elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) clearText, abort due to can't find element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.hasKeyboardFocus != true {
            element?.tap()
        }
        
        if element?.hasKeyboardFocus == true {
            let content:String = element?.value as? String ?? ""
            for _ in content {
                element?.typeText(XCUIKeyboardKey.delete.rawValue)
            }
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) clearText, clear text done")
            dismissKeyboard()
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            dismissKeyboard()
            return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
        }
    }
    
    internal static func isDisplayed(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.lastSnapshot == nil {
            element?.resolve()
        }
        
        let isWDVisible = try? element?.lastSnapshot.isWDEnabled()
        return XCTestWDResponse.response(session: session, value: JSON(isWDVisible as Any))
    }
    
    internal static func getAttribute(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        let attributeName = request.params[":name"]
        
        if elementId == nil || attributeName == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getAttribute, fails to get attribute")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getAttribute, fails to get element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        
        let value = element?.value(forKey: (attributeName?.capitalized)!)
        return XCTestWDResponse.response(session: session, value: JSON(value as Any))
    }
    
    internal static func getRect(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if elementId == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getRect, fails to get elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) getRect, fails to get element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        return XCTestWDResponse.response(session: session, value: JSON(element?.wdRect() as Any))
    }
    
    internal static func tap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let elementId = request.params[":elementId"]
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if element != nil {
            if (element?.isHittable)! && (element?.exists)! {
                element?.tap()
            }

            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) tap, tap element with element 'tap' method")
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            let rawX = getFloatValue(target: request.jsonBody, field: "x")
            let rawY = getFloatValue(target: request.jsonBody, field: "y")
            
            if rawX == nil || rawY == nil {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) tap, invalid x y coordination info")
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
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        
        let rawX = getFloatValue(target: request.jsonBody, field: "x")
        let rawY = getFloatValue(target: request.jsonBody, field: "y")
        
        if rawX == nil || rawY == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) doubleTap, invalid x y coordination info")
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
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let action = request.jsonBody
        
        let rawX = getFloatValue(target: request.jsonBody, field: "x")
        let rawY = getFloatValue(target: request.jsonBody, field: "y")
        
        if rawX == nil || rawY == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) touchAndHold, invalid x y coordination info")
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
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        let action = request.jsonBody
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) touchAndHoldOnElement, invalid element info")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) touchAndHoldOnElement, invalid elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let duration = getDoubleValue(target: action, field: "duration")
        
        element?.press(forDuration: duration ?? 2)
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    
    internal static func dragForDuration(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let action = request.jsonBody
        
        let rawX = getFloatValue(target: action, field: "fromX")
        let rawY = getFloatValue(target: action, field: "fromY")
        let rawToX = getFloatValue(target: action, field: "toX")
        let rawToY = getFloatValue(target: action, field: "toY")
        
        
        if rawX == nil || rawY == nil || rawToX == nil || rawToY == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) dragForDuration, invalid input parameters")
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
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        let action = request.jsonBody
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) pinch, element is null")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) pinch, invalid elementId")
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let scale = CGFloat(getDoubleValue(target: action, field: "scale") ?? 2)
        let velocity = CGFloat(getDoubleValue(target: action, field: "velocity") ?? 1)
        
        element?.pinch(withScale: scale, velocity: velocity)
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func handleTwoElementTap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if element == nil {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) handleTwoElementTap, invalid element")
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if elementId == nil{
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) handleTwoElementTap, invalid elementId")
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
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) Error occured in sending key: \(error.debugDescription)")
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func homeScreen(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(3);
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }    
    
    internal static func doubleTap(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = XCTestWDSessionManager.commonCache.elementForUUID(elementId)
        
        if element != nil {
            if (element?.exists)! && (element?.isHittable)! {
                element?.doubleTap()
            }

            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) doubleTap, doubleTap with element's internal method")
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        } else {
            let rawX = getFloatValue(target: request.jsonBody, field: "x")
            let rawY = getFloatValue(target: request.jsonBody, field: "y")
            
            if rawX == nil || rawY == nil {
                DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) doubleTap, abort due to invalid arguments")
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
    
    private static func dismissKeyboard() {
        XCTestDaemonsProxy.testRunnerProxy()._XCT_send("\n", maximumFrequency: 60) { (error) in
            if error != nil {
                print("Error occured in sending key: \(error.debugDescription)")
            }
        }
    }
}
