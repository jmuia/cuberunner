//
//  HighScores.swift
//  cuberunner
//
//  Created by Joey Muia on 2016-04-03.
//  Copyright © 2016 Joey Muia. All rights reserved.
//

import Foundation

class HighScores {
    private static let sharedInstance = HighScores()
    
    private var scores: [Int]
    
    private init() {
        if let scores = NSUserDefaults.standardUserDefaults().objectForKey("highScores") as! [Int]? {
            self.scores = scores
        } else {
            self.scores = []
        }
    }
    
    static func all() -> [Int] {
        return sharedInstance.scores
    }
    
    static func highest() -> Int {
        if let max = sharedInstance.scores.maxElement() {
            return max
        } else {
            return 0
        }
    }
    
    static func save() {
        NSUserDefaults.standardUserDefaults().setObject(sharedInstance.scores, forKey: "highScores")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func addScore(score: Int) {
        sharedInstance.scores.append(score)
    }
    
    
}