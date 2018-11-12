//
//  XCTestCommandHandler.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Swifter

class RequestRoute: Hashable, Equatable {
  
  internal var path:String!
  internal var verb:String!
  internal var requiresSession:Bool
  
  init(_ path:String , _ verb:String = "GET", _ requiresSession:Bool = true) {
    self.path = path
    self.verb = verb
    self.requiresSession = requiresSession
  }
  
  public var hashValue: Int {
    get {
      return "\(path)_\(verb)_\(requiresSession)".hashValue
    }
  }
  
  public static func ==(lhs: RequestRoute, rhs: RequestRoute) -> Bool {
    return lhs.path == rhs.path && lhs.verb == rhs.verb && lhs.requiresSession == rhs.requiresSession
  }
}

typealias RoutingCall = ((Swifter.HttpRequest) -> Swifter.HttpResponse)

internal protocol Controller {  
  
  static func routes() -> [(RequestRoute, RoutingCall)]
  
  static func shouldRegisterAutomatically() -> Bool
  
}
