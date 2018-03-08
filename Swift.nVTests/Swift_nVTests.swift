//
//  Swift_nVTests.swift
//  Swift.nVTests
//
//  Created by Seth Law on 4/28/17.
//  Copyright © 2017 nVisium. All rights reserved.
//

import XCTest
import CoreData
@testable import Swift_nV

class Swift_nVTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = Swift_nV.deleteUser(nil)
        _ = Swift_nV.deleteItem(nil, nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoreDataUser() {
        let email = "testcoredata@test.com"
        let pass = "testpass"
        let first = "Core"
        let last = "Data"
        
        _ = Swift_nV.registerUser(email,pass,first,last,nil,nil)
        
        let user: User = Swift_nV.getUser(email)!
        
        // Assert that user password != db password
        NSLog("User pass: \(user.password!)")
        XCTAssert(user.password! != pass)
    }
    
    func testCoreDataItem() {
        let name = "itemname"
        let value = "testitemvalue"
        let plainval = value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let b64val = plainval.base64EncodedString()
        let email = "testcoredataitem@test.com"
        
        _ = Swift_nV.addItem(name, value, "these are test notes", email)
        
        let i: Item = Swift_nV.getItemByNameEmail(name, email)!
        
        // Assert that user password != db password
        NSLog("Item val: \(i.value!)")
        XCTAssert(i.value! != b64val)
    }
    
    func testNSUserDefaultsEmail() {
        let defaults : UserDefaults = Swift_nV.UserDefaults.standard
        
        let email = "testNSUserDefaultsEmail@test.com"
        let pass = "testpass"
        let first = "NSUser"
        let last = "Defaults"
        
        _ = Swift_nV.registerUser(email,pass,first,last,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = pass
        
        lvc.login()
        
        let def = defaults.string(forKey: "email")
        NSLog("defaults: \(String(describing: def)), email: \(email)")
        XCTAssert(defaults.string(forKey: "email") != email)
        
    }
    
    func testNSUserDefaultsPIN() {
        let defaults : UserDefaults = Swift_nV.UserDefaults.standard
        
        let email = "testNSUserDefaultsPIN@test.com"
        let pass = "testpass"
        let first = "NSUser"
        let last = "Defaults"
        let pinNumber = "2324"
        
        _ = Swift_nV.registerUser(email,pass,first,last,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = pass
        
        lvc.login()
        
        let svc : NVSettingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! NVSettingsViewController
        UIApplication.shared.keyWindow!.rootViewController = svc as UIViewController
        
        let _ = svc.view
        svc.enablePinFunc(svc.enablePin)
        svc.pinField.text = pinNumber
        svc.pinSave(svc)
        
        XCTAssert(defaults.string(forKey: "PIN") != pinNumber)
    }
    
    func testPlistKey() {
        let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        let key = envs.value(forKey: "CryptoKey")
        
        XCTAssertNil(key)
    }
    
    func testSourcePINInit() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : NVInitViewController = storyboard.instantiateViewController(withIdentifier: "InitViewController") as! NVInitViewController
        UIApplication.shared.keyWindow!.rootViewController = vc as UIViewController
        let _ = vc.view
        vc.setupPreferences(Swift_nV.UserDefaults.standard)
        
        XCTAssertNil(Swift_nV.getPIN())
    }
    
    func testSourcePINSettings() {
        let email = "testNSUserDefaultsPIN@test.com"
        let pass = "testpass"
        let first = "NSUser"
        let last = "Defaults"
        
        _ = Swift_nV.registerUser(email,pass,first,last,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = pass
        
        lvc.login()
        
        let svc : NVSettingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! NVSettingsViewController
        UIApplication.shared.keyWindow!.rootViewController = svc as UIViewController
        
        let _ = svc.view
        svc.enablePinFunc(svc.enablePin)
        svc.logout(svc)
        
        XCTAssertNil(Swift_nV.getPIN())
    }
    
    func testCommSSL() {
        let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        let authURL = envs.value(forKey: "AuthenticateURL") as! String
        let regURL = envs.value(forKey: "RegisterURL") as! String
        let newSecretURL = envs.value(forKey: "NewSecretURL") as! String
        let secretsURL = envs.value(forKey: "SecretsURL") as! String
        let updateSecretURL = envs.value(forKey: "UpdateSecretURL") as! String
        var passed :Bool = true
        
        if authURL.range(of: "https") == nil {
            passed = false
            NSLog("\(authURL) is not secure")
        }
        if regURL.range(of: "https") == nil {
            passed = false
            NSLog("\(regURL) is not secure")
        }
        if newSecretURL.range(of: "https") == nil {
            passed = false
            NSLog("\(newSecretURL) is not secure")
        }
        if secretsURL.range(of: "https") == nil {
            passed = false
            NSLog("\(secretsURL) is not secure")
        }
        if updateSecretURL.range(of: "https") == nil {
            passed = false
            NSLog("\(updateSecretURL) is not secure")
        }
        
        XCTAssertTrue(passed)
    }
    
    func testCommAppTransport() {
        let infoPlist = Bundle.main.path(forResource: "Info", ofType: "plist")
        let info = NSDictionary(contentsOfFile: infoPlist!)!
        let apptransport = info["NSAppTransportSecurity"] as! NSDictionary
        
        XCTAssertFalse((apptransport["NSAllowsArbitraryLoads"] as? Bool)!)
        //XCTAssertFalse(info.value(forKey: "NSAppTransportSecurity").value(value(forKey: "NSAllowsArbitraryLoads")))
    }
    
    func testAuthZItem() {
        var passed = true
        let email = "testAuthZItem@test.com"
        let pass1 = "testpass1"
        let first1 = "AuthZ"
        let last1 = "Item"
        
        _ = Swift_nV.registerUser(email,pass1,first1,last1,nil,nil)
        
        let name = "itemname"
        let value = "testitemvalue"
        
        _ = Swift_nV.addItem(name, value, "these are test notes", email)
        
        let pass2 = "testpass2"
        let first2 = "AuthZ2"
        let last2 = "Item2"
        
        let user2 = Swift_nV.registerUser(email,pass2,first2,last2,nil,nil)
        
        if (user2 != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
            UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
            let _ = lvc.view
            lvc.username.text = email
            lvc.password.text = pass2
            
            lvc.login()
            
            let hvc : NVHomeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! NVHomeViewController
            UIApplication.shared.keyWindow!.rootViewController = hvc as UIViewController
            let _ = hvc.view
            
            let ivc : NVItemsTableViewController = storyboard.instantiateViewController(withIdentifier: "ItemTableViewController") as! NVItemsTableViewController
            UIApplication.shared.keyWindow!.rootViewController = ivc as UIViewController
            let _ = ivc.view
            ivc.viewDidAppear(true)
            //sleep(5)
            var cell: UITableViewCell?
            for i in 0...ivc.tableView.numberOfSections-1 {
                for j in 0...ivc.tableView.numberOfRows(inSection: i)-1 {
                    cell = ivc.tableView.cellForRow(at: IndexPath(row: j, section: i))
                    if (cell?.textLabel!.text == name) {
                        passed = false
                    }
                }
            }
        }
        
        XCTAssertTrue(passed)
        
    }
    
    func testAuthNPIN() {
        var passed = true
        let email = "testAuthNPIN@test.com"
        let pass1 = "testpass3"
        let first1 = "AuthN"
        let last1 = "PIN"
        let pinNumber = "1"
        
        _ = Swift_nV.registerUser(email,pass1,first1,last1,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = pass1
        
        lvc.login()
        
        let svc : NVSettingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! NVSettingsViewController
        UIApplication.shared.keyWindow!.rootViewController = svc as UIViewController
        
        let _ = svc.view
        svc.enablePinFunc(svc.enablePin)
        svc.pinField.text = pinNumber
        svc.pinSave(svc)
        
        let plvc : NVPinLoginViewController = storyboard.instantiateViewController(withIdentifier: "PinViewController") as! NVPinLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = plvc as UIViewController
        
        let _ = plvc.view
        plvc.pin.text = pinNumber
        plvc.go(plvc)
        
        if (plvc.message.text! != "INCORRECT PIN!!") {
            passed = false
        }
        
        XCTAssertTrue(passed)
        
    }
    
    func testAuthNUserEnum() {
        var passed = true
        let email = "testAuthNUserEnum@test.com"
        let pass1 = "testpassue"
        let first1 = "AuthNUser"
        let last1 = "Enum"
        
        _ = Swift_nV.registerUser(email,pass1,first1,last1,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = "badpassword"
        
        lvc.login()
        
        let bpmessage = lvc.message.text
        
        let _ = lvc.view
        lvc.username.text = "bad@email.com"
        lvc.password.text = "badpassword"
        
        lvc.login()
        
        let bumessage = lvc.message.text
        
        if (bpmessage != bumessage) {
            passed = false
        }
        
        XCTAssertTrue(passed)
        
    }
    
    func testLoginSensitiveFields() {
        var passed = true
        let email = "testLoginSensitiveFields@test.com"
        let pass1 = "testpass4"
        let first1 = "Sensitive"
        let last1 = "Fields"
        
        _ = Swift_nV.registerUser(email,pass1,first1,last1,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        lvc.username.text = email
        lvc.password.text = pass1
        
        lvc.login()
        
        let hvc : NVHomeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! NVHomeViewController
        UIApplication.shared.keyWindow!.rootViewController = hvc as UIViewController
        let _ = hvc.view
        
        if (lvc.username.text! == email && lvc.password.text! == pass1) {
            passed = false
        }
        
        XCTAssertTrue(passed)
        
    }
    
    func testRegisterSensitiveFields() {
        var passed = true
        let email = "testRegisterSensitiveFields@test.com"
        let pass1 = "testpass5"
        let first1 = "Sensitive"
        let last1 = "Fields"
        
        //_ = Swift_nV.registerUser(email,pass1,first1,last1,nil,nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rvc : NVRegisterViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! NVRegisterViewController
        UIApplication.shared.keyWindow!.rootViewController = rvc as UIViewController
        let _ = rvc.view
        rvc.email.text = email
        rvc.password1.text = pass1
        rvc.password2.text = pass1
        rvc.firstname.text = first1
        rvc.lastname.text = last1
        
        rvc.register(rvc)
        
        let lvc : NVLoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! NVLoginViewController
        UIApplication.shared.keyWindow!.rootViewController = lvc as UIViewController
        let _ = lvc.view
        
        if (rvc.email.text! == email && rvc.password1.text! == pass1) {
            passed = false
        }
        
        XCTAssertTrue(passed)
        
    }
    
    
    /*func testPerformanceExample() {
     // This is an example of a performance test case.
     self.measure {
     // Put the code you want to measure the time of here.
     }
     }*/
    
}

