//
//  GitHubAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SignupState: Equatable {
    case InitialState
    case SigningUp
    case SignedUp(signedUp: Bool)
}

func ==(lhs: SignupState, rhs: SignupState) -> Bool {
    switch (lhs, rhs) {
    case (.InitialState, .InitialState):
        return true
    case (.SigningUp, .SigningUp):
        return true
    case (.SignedUp(let lhsSignup), .SignedUp(let rhsSignup)):
        return lhsSignup == rhsSignup
    default:
        return false
    }
}

class GitHubAPI {
    let dataScheduler: ImmediateScheduler
    let URLSession: NSURLSession

    init(dataScheduler: ImmediateScheduler, URLSession: NSURLSession) {
        self.dataScheduler = dataScheduler
        self.URLSession = URLSession
    }
    
    func usernameAvailable(username: String) -> Observable<Bool> {
        // this is ofc just mock, but good enough
        
        let URL = NSURL(string: "https://github.com/\(URLEscape(username))")!
        let request = NSURLRequest(URL: URL)
        return self.URLSession.rx_response(request)
            >- map { (maybeData, maybeResponse) in
                if let response = maybeResponse as? NSHTTPURLResponse {
                    return response.statusCode == 404
                }
                else {
                    return false
                }
            }
            >- observeSingleOn(self.dataScheduler)
            >- catch { result in
                return returnElement(false)
            }
    }
    
    func signup(username: String, password: String) -> Observable<SignupState> {
        // this is also just a mock
        let signupResult = SignupState.SignedUp(signedUp: arc4random() % 5 == 0 ? false : true)
        return concat([returnElement(signupResult), never()])
            >- throttle(5000, MainScheduler.sharedInstance)
            >- startWith(SignupState.SigningUp)
    }
}