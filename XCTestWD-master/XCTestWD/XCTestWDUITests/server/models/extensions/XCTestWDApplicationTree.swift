//
//  XCTestWDApplicationTree.swift
//  XCTestWD
//
//  Created by zhaoy on 5/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import SwiftyJSON

extension XCUIApplication {

    func mainWindowSnapshot() -> XCElementSnapshot? {
        let mainWindows = (self.lastSnapshot() as! XCElementSnapshot).descendantsByFiltering { (snapshot) -> Bool in
            return snapshot?.isMainWindow ?? false
        }
        return mainWindows?.last
    }
}
