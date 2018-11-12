//
//  XCUIElementTypeTransformer.swift
//  XCTestWD
//
//  Created by zhaoy on 29/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

class XCUIElementTypeTransformer {
    
    var elementStringMapping:[UInt:String]
    var stringElementMapping:[String:UInt]
    
    static let singleton = XCUIElementTypeTransformer()
    
    private init() {
        elementStringMapping = [
             0 : "XCUIElementTypeAny",
             1 : "XCUIElementTypeOther",
             2 : "XCUIElementTypeApplication",
             3 : "XCUIElementTypeGroup",
             4 : "XCUIElementTypeWindow",
             5 : "XCUIElementTypeSheet",
             6 : "XCUIElementTypeDrawer",
             7 : "XCUIElementTypeAlert",
             8 : "XCUIElementTypeDialog",
             9 : "XCUIElementTypeButton",
            10 : "XCUIElementTypeRadioButton",
            11 : "XCUIElementTypeRadioGroup",
            12 : "XCUIElementTypeCheckBox",
            13 : "XCUIElementTypeDisclosureTriangle",
            14 : "XCUIElementTypePopUpButton",
            15 : "XCUIElementTypeComboBox",
            16 : "XCUIElementTypeMenuButton",
            17 : "XCUIElementTypeToolbarButton",
            18 : "XCUIElementTypePopover",
            19 : "XCUIElementTypeKeyboard",
            20 : "XCUIElementTypeKey",
            21 : "XCUIElementTypeNavigationBar",
            22 : "XCUIElementTypeTabBar",
            23 : "XCUIElementTypeTabGroup",
            24 : "XCUIElementTypeToolbar",
            25 : "XCUIElementTypeStatusBar",
            26 : "XCUIElementTypeTable",
            27 : "XCUIElementTypeTableRow",
            28 : "XCUIElementTypeTableColumn",
            29 : "XCUIElementTypeOutline",
            30 : "XCUIElementTypeOutlineRow",
            31 : "XCUIElementTypeBrowser",
            32 : "XCUIElementTypeCollectionView",
            33 : "XCUIElementTypeSlider",
            34 : "XCUIElementTypePageIndicator",
            35 : "XCUIElementTypeProgressIndicator",
            36 : "XCUIElementTypeActivityIndicator",
            37 : "XCUIElementTypeSegmentedControl",
            38 : "XCUIElementTypePicker",
            39 : "XCUIElementTypePickerWheel",
            40 : "XCUIElementTypeSwitch",
            41 : "XCUIElementTypeToggle",
            42 : "XCUIElementTypeLink",
            43 : "XCUIElementTypeImage",
            44 : "XCUIElementTypeIcon",
            45 : "XCUIElementTypeSearchField",
            46 : "XCUIElementTypeScrollView",
            47 : "XCUIElementTypeScrollBar",
            48 : "XCUIElementTypeStaticText",
            49 : "XCUIElementTypeTextField",
            50 : "XCUIElementTypeSecureTextField",
            51 : "XCUIElementTypeDatePicker",
            52 : "XCUIElementTypeTextView",
            53 : "XCUIElementTypeMenu",
            54 : "XCUIElementTypeMenuItem",
            55 : "XCUIElementTypeMenuBar",
            56 : "XCUIElementTypeMenuBarItem",
            57 : "XCUIElementTypeMap",
            58 : "XCUIElementTypeWebView",
            59 : "XCUIElementTypeIncrementArrow",
            60 : "XCUIElementTypeDecrementArrow",
            61 : "XCUIElementTypeTimeline",
            62 : "XCUIElementTypeRatingIndicator",
            63 : "XCUIElementTypeValueIndicator",
            64 : "XCUIElementTypeSplitGroup",
            65 : "XCUIElementTypeSplitter",
            66 : "XCUIElementTypeRelevanceIndicator",
            67 : "XCUIElementTypeColorWell",
            68 : "XCUIElementTypeHelpTag",
            69 : "XCUIElementTypeMatte",
            70 : "XCUIElementTypeDockItem",
            71 : "XCUIElementTypeRuler",
            72 : "XCUIElementTypeRulerMarker",
            73 : "XCUIElementTypeGrid",
            74 : "XCUIElementTypeLevelIndicator",
            75 : "XCUIElementTypeCell",
            76 : "XCUIElementTypeLayoutArea",
            77 : "XCUIElementTypeLayoutItem",
            78 : "XCUIElementTypeHandle",
            79 : "XCUIElementTypeStepper",
            80 : "XCUIElementTypeTab"]
        
        stringElementMapping = [String:UInt]()
        for (key, value) in elementStringMapping {
            stringElementMapping[value] = key
        }
    }
    
    func elementTypeWithTypeName(_ typeName:String) -> XCUIElement.ElementType {
        return XCUIElement.ElementType(rawValue: stringElementMapping[typeName]!)!
    }
    
    func stringWithElementType(_ elementType:XCUIElement.ElementType) -> String {
        return elementStringMapping[elementType.rawValue]!
    }
    
    func shortStringWithElementType(_ elementType:XCUIElement.ElementType) -> String {
        return stringWithElementType(elementType).replacingOccurrences(of: "XCUIElementType", with: "")
    }
    
}
