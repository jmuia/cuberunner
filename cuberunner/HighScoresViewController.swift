//
//  HighScoresViewController.swift
//  cuberunner
//
//  Created by Joey Muia on 2016-04-03.
//  Copyright © 2016 Joey Muia. All rights reserved.
//

import UIKit

class HighScoresViewController: UITableViewController {
    var scores = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scores = HighScores.all().sort({ $0 > $1})
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("ScoreCell", forIndexPath: indexPath)
            let score = scores[indexPath.row]
            
            cell.textLabel?.text = "\(indexPath.row + 1). \(score)"
            return cell
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
