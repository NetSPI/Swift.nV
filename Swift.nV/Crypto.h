//
//  Crypto.h
//  Swift.nV
//
//  Created by John on 7/25/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface Crypto : NSObject

- (NSString*) sha256HashFor:(NSString*)input;

@end