//
//  EncryptedUserDefaults.h
//  EncryptedUserDefaults
//
//  Created by Shubham Aggarwal on 06/04/16.
//  Copyright © 2016 Sort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptedUserDefaults : NSObject

-(id)initWithName:(NSString *)name andProtectionKey:(NSString *)protectionKey;

-(void)setObject:(NSObject *)object forKey:(NSString *)aKey;
-(NSObject *)objectForKey:(NSString *)key;
-(void)deleteObjectForKey:(NSString *)key;

-(void)forceStore;

@end


//Usage:
//EncryptedUserDefaults *ecd = [EncryptedUserDefaults alloc] initWithName:@"abcd.json" andProtectionKey:@"ojndc230iajncas"];
