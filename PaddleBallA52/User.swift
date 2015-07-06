//
//  User.swift
//  Autolayout
//
//  Created by iMac21.5 on 4/21/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import Foundation
struct User {
    let name: String
    let company: String?
    let highScore: String?
    let highScoreDate: String?
    let login: String
    let password: String
    var lastLogin = NSDate.demoRandom()
    
    init(name: String, company: String, highScore: String, highScoreDate: String, login: String, password: String) {
        self.name = name
        self.company = company
        self.highScore = highScore
        self.highScoreDate = highScoreDate
        self.login = login
        self.password = password
    }
    
    static func login(login: String, password: String) -> User? {
        if let user = database[login] {
            if user.password == password {
            return user
            }
        }
        return User.login("baddie", password: "foo")
    }
    
    static let database: Dictionary<String, User> = {
        var theDatabase = Dictionary<String, User>()
        for user in [
            User(name: "Johny Appleseed", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "japple", password: "foo"),
            User(name: "Madison Bumgarner", company: "World Champion San Francisco Giants", highScore: "18,222", highScoreDate: "2015-05-11", login: "madbum", password: "foo"),
            User(name: "John Hennessy", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "cufi100", password: "foo"),
            User(name: "Bad Guy", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "baddie", password: "foo"),
            User(name: "Good Guy", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "soccer", password: "foo")
            ] {
            theDatabase[user.login] = user
        }
        return theDatabase
    }()
}

private extension NSDate {
    class func demoRandom() -> NSDate {
        let randomIntervalIntoThePast = -Double(arc4random() % 60*60*24*20)
        return NSDate(timeIntervalSinceNow: randomIntervalIntoThePast)
    }
}
