//
//  NVWebViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 8/19/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVWebViewController: UIViewController {
    @IBOutlet weak var wv: UIWebView!
    @IBOutlet weak var refresh: UIBarButtonItem!
    @IBOutlet weak var stop: UIBarButtonItem!
    @IBOutlet weak var prevButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var tURL: String = ""
    var lastTut: Int = 8
    var curTut: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        self.tURL = envs.value(forKey: "TutorialURL") as! String
        
        self.wv.loadRequest(URLRequest(url: URL(string: "\(self.tURL)/m\(self.curTut)")!))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func prevTutorial(_ sender: AnyObject) {
        if self.curTut == 1 {
            self.curTut = self.lastTut
        } else {
            self.curTut = self.curTut-1
        }
        self.wv.loadRequest(URLRequest(url: URL(string: "\(self.tURL)/m\(self.curTut)")!))
    }
    @IBAction func nextTutorial(_ sender: AnyObject) {
        if self.curTut == self.lastTut {
            self.curTut = 1
        } else {
            self.curTut = self.curTut + 1
        }
        self.wv.loadRequest(URLRequest(url: URL(string: "\(self.tURL)/m\(self.curTut)")!))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
