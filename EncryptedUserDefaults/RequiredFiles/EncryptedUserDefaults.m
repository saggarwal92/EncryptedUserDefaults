//
//  EncryptedUserDefaults.m
//  EncryptedUserDefaults
//
//  Created by Shubham Aggarwal on 06/04/16.
//  Copyright © 2016 Sort. All rights reserved.
//

#import "EncryptedUserDefaults.h"
#import "RNCryptor.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

const static NSInteger AUTO_TIMEOUT_INTERVAL = 60 * 4;  //4 minutes

@interface EncryptedUserDefaults()
@property (readonly,nonatomic,strong) NSString *filename;
@property (readonly,nonatomic,strong) NSString *protectionKey;

@property (readonly,nonatomic,strong) NSMutableDictionary *dictionary;
@property (nonatomic,retain) NSTimer *timeOutTimer; //To Release Data Automatically After SomeTime if It is Not Read

@property (nonatomic,retain) NSObject *lock;
@property (nonatomic,assign) BOOL isUpdated;
@end

@implementation EncryptedUserDefaults

- (instancetype)init
{
    self = [self initWithName:@"epct_default.txt" andProtectionKey:@"kndsfwirjb32oajkcsd"];
    return self;
}

-(id)initWithName:(NSString *)name andProtectionKey:(NSString *)protectionKey{
    self = [super init];
    if(self){
        _isUpdated = NO;
        _lock = [[NSObject alloc] init];
        _protectionKey = protectionKey;
        _filename = [NSString stringWithFormat:@"sort_%@",name];
        _filename = [self saveFilePath];
    }
    return self;
}

-(NSString*)saveFilePath    {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathString = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:self.filename];
    return pathString;
}


//ObjectForKey
-(NSObject *)objectForKey:(NSString *)key{
    @synchronized(_lock) {
        if(_timeOutTimer){
            [_timeOutTimer invalidate];
        }
        if(self.dictionary == nil){
            [self load];
        }
        
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_TIMEOUT_INTERVAL target:self selector:@selector(autoReleaseData) userInfo:nil repeats:NO];
        return [self.dictionary objectForKey:key];
    }
}

-(void)setObject:(NSObject *)object forKey:(NSString *)aKey{
    @synchronized(_lock) {
        if(_timeOutTimer){
            [_timeOutTimer invalidate];
        }
        if(self.dictionary == nil){
            [self load];
        }
        
        _isUpdated = YES;
        [self.dictionary setObject:object forKey:aKey];
        
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_TIMEOUT_INTERVAL target:self selector:@selector(autoReleaseData) userInfo:nil repeats:NO];
    }
}

-(void)deleteObjectForKey:(NSString *)key{
    @synchronized(_lock) {
        if(_timeOutTimer){
            [_timeOutTimer invalidate];
        }
        if(self.dictionary == nil){
            [self load];
        }
        
        _isUpdated = YES;
        [self.dictionary removeObjectForKey:key];
        
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_TIMEOUT_INTERVAL target:self selector:@selector(autoReleaseData) userInfo:nil repeats:NO];
    }
}
//ObjectForKey


-(void)load{
    NSData *data = [NSData dataWithContentsOfFile:self.filename];
    if(data){
        NSError *error;
        data = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:self.protectionKey error:&error];
        if(error){
        //NSLog(@"==>Error while Decrypting Data: %@",error);
        }
        //Decrypt Data
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _dictionary = [dictionary mutableCopy];
    }else{
        _dictionary = [NSMutableDictionary dictionary];
    }
}

-(void)forceStore{
    @synchronized(_lock) {
        if(_dictionary){
            [self storeDictionary:[_dictionary copy]];
        }
    }
}

-(void)storeDictionary:(NSDictionary *)dictionary{
    if(_isUpdated == YES){
        NSData *data = nil;
        if(_dictionary){
            data = [NSKeyedArchiver archivedDataWithRootObject:_dictionary];
        }else{
            data = [NSData data];
        }
        //Encrypt Data And Store In File
        NSError *error;
        data = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:self.protectionKey error:&error];
        if(error){
        //NSLog(@"==>Error while Encrypting Data: %@",error);
        }
        if(data)    [data writeToFile:_filename atomically:YES];
        
        _isUpdated = NO;
    }else{
    //NSLog(@"Data Not Updated");
    }
}


-(void)autoReleaseData{
    @synchronized(_lock) {
        _timeOutTimer = nil;
        NSDictionary *dictionary = _dictionary;
        _dictionary = nil;
        if(dictionary){
            [self storeDictionary:dictionary];
        }
    }
}



@end
