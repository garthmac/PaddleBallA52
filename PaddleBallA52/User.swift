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
    
    static func login(login: String, password: String) -> User {
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
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "vector300", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u207", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "starDavid", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "dizzy2", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u212Bar", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "audio77", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "audio78", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "audio66", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "audio90", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "audio96", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "audio125", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "audio190", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "audio209", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "audio223", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "audio3", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "audio7", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "back", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "u5", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "u6", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u70", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "u73", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "u75", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "u117", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "u120", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u225", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "u77", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "wheel160", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "wheelOf160", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "vector160", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "steer160", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "skateW160", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "ship160", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "radios160", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "prowheel160", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "orangeW160", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "gold160", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "FFWD160", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "edd2160", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "cvision160", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "cool160", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "burning160", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "blue160", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "bicycle160", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "art160", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "toyota160", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "citroen160", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "u29ID", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "pickle178", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "pickle180", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "pickle190", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "pink130", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "arrow300", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "ball283", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "butterfly", password: "foo"),
            User(name: "Madison", company: "World", highScore: "18,222", highScoreDate: "2015-05-11", login: "color265", password: "foo"),
            User(name: "John", company: "Stanford", highScore: "999", highScoreDate: "2015-06-20", login: "cool275", password: "foo"),
            User(name: "Bad", company: "Criminals, Inc.", highScore: "6,666", highScoreDate: "2015-06-06", login: "image210", password: "foo"),
            User(name: "Good", company: "Rescue, Inc.", highScore: "8,888", highScoreDate: "2015-06-21", login: "ok128", password: "foo"),
            User(name: "Johny", company: "Apple", highScore: "10,222", highScoreDate: "2015-04-01", login: "cyan158", password: "foo")
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
