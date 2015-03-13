//
//  NoticeViewController.swift
//  ECSlidingViewControllerSample
//
//  Created by Hiroki Yoshifuji on 2015/03/12.
//  Copyright (c) 2015年 Hiroki Yoshifuji. All rights reserved.
//

import UIKit

class NoticeViewController : UITableViewController {
    
    @IBAction func tappedCloseButton(sender: AnyObject) {
        
        self.slidingViewController().resetTopViewAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Notice viewDidLoad")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        if let root = self.slidingViewController() as? RootViewController {
            self.view.addGestureRecognizer(root.panGesture)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        println("Notice viewDidDisappear")
        
        if let root = self.slidingViewController() as? RootViewController {
            self.view.removeGestureRecognizer(root.panGesture)
            self.slidingViewController().topViewController.view.addGestureRecognizer(root.panGesture)
        }
    }
}
