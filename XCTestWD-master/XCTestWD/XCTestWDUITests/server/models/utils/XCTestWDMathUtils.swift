//
//  XCTestWDMathUtils.swift
//  XCTestWD
//
//  Created by zhaoy on 5/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

class MathUtils {
    
    static func adjustDimensionsForApplication(_ actualSize:CGSize , _ orientation:UIDeviceOrientation) -> CGSize {
        if (orientation ==  UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight) {
            /*
             There is an XCTest bug that application.frame property returns exchanged dimensions for landscape mode.
             This verification is just to make sure the bug is still there (since height is never greater than width in landscape)
             and to make it still working properly after XCTest itself starts to respect landscape mode.
             */
            if (actualSize.height > actualSize.width) {
                return CGSize(width:actualSize.height, height:actualSize.width)
            }
        }
        return actualSize;
    }
    
    static func MD5(string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.base64EncodedString()
    }

}
