//
//  ItemHelper.swift
//  Swift.nV
//
//  Created by Seth Law on 7/31/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import Foundation
import Security

func encryptString(_ toEncrypt: String) -> String {

    let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
    let envs = NSDictionary(contentsOfFile: envPlist!)!
    let cryptoKey = envs.value(forKey: "CryptoKey") as! String

    // Create Ciphertext
    let plainText = (toEncrypt as NSString).data(using: String.Encoding.utf8.rawValue)!
    let cipherText = (plainText as NSData).aes256Encrypt(withKey: cryptoKey)

    let ret = cipherText?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    
    NSLog("Encrypting \(toEncrypt) as \(ret)")
    
    return ret!
}

func decryptString(_ toDecrypt: String) -> String {
    let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
    let envs = NSDictionary(contentsOfFile: envPlist!)!
    let cryptoKey = envs.value(forKey: "CryptoKey") as! String
    
    // Create PlainText
    let cipherData = Data(base64Encoded: toDecrypt, options: NSData.Base64DecodingOptions(rawValue: 0))!
    let cipherText = (cipherData as NSData).aes256Decrypt(withKey: cryptoKey)
    let ret = String.init(data: cipherText!, encoding: String.Encoding.utf8)
    
    NSLog("Decrypting \(toDecrypt) as \(ret!)")
    
    return ret!
}

func generateChecksum(_ myItem: Item) -> String {
    let crypto: Crypto = Crypto()
    return crypto.sha256Hash(for: "\(myItem.name)\(myItem.value)\(myItem.notes)")
}

/* Example of using keychain for storing data
func saveToKeychain(key: String, data: String) {
    do {
        try Locksmith.saveData([key:data], forUserAccount: "swift-nv")
    } catch let err as NSError {
        NSLog("Error: %@", err)
    }
    NSLog("Saved \(key):\(data) to keychain")

}

func loadFromKeychain(key: String) -> String? {
    let dict = Locksmith.loadDataForUserAccount("swift-nv")
    if (dict != nil) {
        if (dict![key] != nil) {
            return dict![key] as! String
        }
    }
    return nil
}
 */
