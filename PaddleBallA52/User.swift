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
            User(name: "Good Guy", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "soccer", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "8ball", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "asian", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "asian33", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "baseball", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "basketball", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "bully72", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "c14", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "cd114", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "cd115", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "dizzy34", password: "foo"),
            User(name: "Madi", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "happy160", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "r21", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "ring", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "soccer206", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "star18", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "star57", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "sun56", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "sun94", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "tennis80", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u157", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "u158", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "u191", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u193", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "u194", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u195", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "u196", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "u197", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u199", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "u200", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u201", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "u202", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "u203", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u204", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "u205", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u207", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "starDavid", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "dizzy2", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "fireball1", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "fireball2", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "Unknown-52", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "Unknown-66", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "Unknown-90", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "Unknown-96", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "Unknown-125", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "Unknown-190", password: "foo")
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
