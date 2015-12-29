//
//  ItemHelper.swift
//  Swift.nV
//
//  Created by Seth Law on 7/31/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import Foundation

func encryptString(toEncrypt: String) -> String {

    let envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
    let envs = NSDictionary(contentsOfFile: envPlist!)!
    let cryptoKey = envs.valueForKey("CryptoKey") as! String

    // Create Ciphertext
    let plainText = (toEncrypt as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
    let cipherText = plainText.AES256EncryptWithKey(cryptoKey)

    let ret = cipherText.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    
    NSLog("Encrypting \(toEncrypt) as \(ret)")
    
    return ret
}

func decryptString(toDecrypt: String) -> String {
    let envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
    let envs = NSDictionary(contentsOfFile: envPlist!)!
    let cryptoKey = envs.valueForKey("CryptoKey") as! String
    
    // Create PlainText
    let cipherData = NSData(base64EncodedString: toDecrypt, options: NSDataBase64DecodingOptions(rawValue: 0))!
    let cipherText = cipherData.AES256DecryptWithKey(cryptoKey)
    let ret = String.init(data: cipherText, encoding: NSUTF8StringEncoding)
    
    NSLog("Decrypting \(toDecrypt) as \(ret!)")
    
    return ret!
}

func generateChecksum(myItem: Item) -> String {
    let crypto: Crypto = Crypto()
    return crypto.sha256HashFor("\(myItem.name)\(myItem.value)\(myItem.notes)")
}