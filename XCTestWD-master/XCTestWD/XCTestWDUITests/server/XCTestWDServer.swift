//
//  XCTestWebDriverServer.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter

public class XCTestWDServer {
    
    private let server = HttpServer()
    
    internal func startServer() {
        do {
            try server.start(fetchPort())
            registerRouters()
            
            NSLog("\(Bundle.main.bundleIdentifier!)")
            
            
            NSLog("XCTestWDSetup->http://localhost:\(try! server.port())<-XCTestWDSetup")
            RunLoop.main.run()
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    internal func stopServer() {
        server.stop()
    }
    
    private func registerRouters() {
        
        var controllers = [Controller]()
        
        controllers.append(XCTestWDActionsController())
        controllers.append(XCTestWDAlertController())
        controllers.append(XCTestWDContextController())
        controllers.append(XCTestWDElementController())
        controllers.append(XCTestWDExecuteController())
        controllers.append(XCTestWDKeysController())
        controllers.append(XCTestWDScreenshotController())
        controllers.append(XCTestWDSessionController())
        controllers.append(XCTestWDSourceController())
        controllers.append(XCTestWDStatusController())
        controllers.append(XCTestWDTimeoutController())
        controllers.append(XCTestWDTitleController())
        controllers.append(XCTestWDElementController())
        controllers.append(XCTestWDWindowController())
        controllers.append(XCTestWDUrlController())
        controllers.append(XCTestWDMonkeyController())
        
        for controller in controllers {
            let routes = type(of: controller).routes()
            for i in 0...routes.count - 1 {
                let (router, requestHandler) = routes[i]
                var routeMethod: HttpServer.MethodRoute?
                
                switch router.verb {
                case "post","POST":
                    routeMethod = server.POST
                    break
                case "get","GET":
                    routeMethod = server.GET
                    break
                case "put", "PUT":
                    routeMethod = server.PUT
                    break
                case "delete", "DELETE":
                    routeMethod = server.DELETE
                    break
                case "update", "UPDATE":
                    routeMethod = server.UPDATE
                    break
                default:
                    routeMethod = nil
                    break
                }
                
                routeMethod?[router.path] = RouteOnMain(requestHandler)
            }
        }
    }
    
    private func fetchPort() -> in_port_t {
        
        let arguments = ProcessInfo.processInfo.arguments
        let index = arguments.index(of: "--port")
        var startingPort:Int = Int(portNumber())
        if index != nil {
            if index! != NSNotFound || index! < arguments.count - 1{
                startingPort = Int(arguments[index!+1])!
            }
        }
        
        var (isValid, _) = checkTcpPortForListen(port: in_port_t(startingPort))
        while isValid == false {
            startingPort = startingPort + 1
            (isValid, _) = checkTcpPortForListen(port: in_port_t(startingPort))
        }
        
        return in_port_t(startingPort)
    }
    
    //MARK: Check Port is occupied
    func checkTcpPortForListen(port: in_port_t) -> (Bool, descr: String){
        
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return (false, "SocketCreationFailed, \(descriptionOfLastError())")
        }
        
        var addr = sockaddr_in()
        addr.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))

        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(MemoryLayout<sockaddr_in>.size))
        
        if bind(socketFileDescriptor, &bind_addr, socklen_t(MemoryLayout<sockaddr_in>.size)) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), BindFailed, \(details)")
        }
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), ListenFailed, \(details)")
        }
        release(socket: socketFileDescriptor)
        return (true, "\(port) is free for use")
    }
    
    func release(socket: Int32) {
        _ = Darwin.shutdown(socket, SHUT_RDWR)
        close(socket)
    }
    
    func descriptionOfLastError() -> String {
        return "Error: \(errno)"
    }
}
