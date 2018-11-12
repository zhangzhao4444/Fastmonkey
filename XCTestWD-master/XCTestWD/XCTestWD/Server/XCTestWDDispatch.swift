//
//  XCTestWDDispatch.swift
//  XCTestWD
//
//  Created by zhaoy on 25/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import Swifter

//MARK: synchronous execution on main
func SyncOnMain(_ executionBlock:(()->(HttpResponse))!) -> HttpResponse {
    var response: HttpResponse = HttpResponse.internalServerError
    DispatchQueue.main.sync {
        response = executionBlock()
    }
    return response
}

func RouteOnMain(_ routingCall:@escaping RoutingCall) -> RoutingCall {
    return { (request: HttpRequest) -> HttpResponse in
        var response:HttpResponse = HttpResponse.internalServerError
        DispatchQueue.main.sync {
            response = routingCall(request)
        }
        return response
    }
}
