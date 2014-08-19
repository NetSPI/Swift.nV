//
//  NVHomeViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVHomeViewController: UITabBarController {
    
    var appUser : User!
    
    /*required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // #pragma mark - Navigation

    /*// In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Settings" {
            var dv : NVSettingsViewController = segue.destinationViewController as NVSettingsViewController
            dv.appUser = self.appUser
        }
    }*/

}
