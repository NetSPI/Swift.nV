//
//  NVInitViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/3/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVInitViewController: UIViewController {

    @IBOutlet var message : UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.message.text = "loading"
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5), target: self, selector: Selector("updateMessage"), userInfo: nil, repeats: false)
        //NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5), invocation: <#NSInvocation?#>, repeats: <#Bool#>)
        // Do any additional setup after loading the view.
    }
    
    func updateMessage() {
        self.message.text = "press the big orange dot"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
