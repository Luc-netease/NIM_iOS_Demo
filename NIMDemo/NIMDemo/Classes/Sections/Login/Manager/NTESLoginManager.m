//
//  NTESLoginManager.m
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESLoginManager.h"
#import "NTESFileLocationHelper.h"


#define NIMAccount      @"account"
#define NIMToken        @"token"
#define NIMAuthType     @"authType"
#define NIMLoginExt     @"loginExt"

@interface NTESLoginData ()<NSCoding>

@end

@implementation NTESLoginData

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _account = [aDecoder decodeObjectForKey:NIMAccount];
        _token = [aDecoder decodeObjectForKey:NIMToken];
        _authType = [[aDecoder decodeObjectForKey:NIMAuthType] intValue];
        _loginExtension = [aDecoder decodeObjectForKey:NIMLoginExt];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_account length]) {
        [encoder encodeObject:_account forKey:NIMAccount];
    }
    if ([_token length]) {
        [encoder encodeObject:_token forKey:NIMToken];
    }
    [encoder encodeObject:@(_authType) forKey:NIMAuthType];
    if ([_loginExtension length]) {
        [encoder encodeObject:_loginExtension forKey:NIMLoginExt];
    }
}

- (BOOL)isValid {
    if (_authType == NIMSDKAuthTypeDefault) {
        return [_account length] && [_token length];
    }

    if (_authType == NIMSDKAuthTypeDynamicToken) {
        return [_account length] && [_token length];
    }

    if (_authType == NIMSDKAuthTypeThirdParty) {
        return [_account length] && [_token length] && [_loginExtension length];
    }

    return NO;
}


@end

@interface NTESLoginManager ()
@property (nonatomic,copy)  NSString    *filepath;
@end

@implementation NTESLoginManager

+ (instancetype)sharedManager
{
    static NTESLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[NTESFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:@"nim_sdk_ntes_login_data"];
        instance = [[NTESLoginManager alloc] initWithPath:filepath];
    });
    return instance;
}


- (instancetype)initWithPath:(NSString *)filepath
{
    if (self = [super init])
    {
        _filepath = filepath;
        [self readData];
    }
    return self;
}


- (void)setCurrentLoginData:(NTESLoginData *)currentLoginData
{
    _currentLoginData = currentLoginData;
    [self saveData];
}

//从文件中读取和保存用户名密码,建议上层开发对这个地方做加密,DEMO只为了做示范,所以没加密
- (void)readData
{
    NSString *filepath = [self filepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        _currentLoginData = [object isKindOfClass:[NTESLoginData class]] ? object : nil;
    }
}

- (void)saveData
{
    NSData *data = [NSData data];
    if (_currentLoginData)
    {
        data = [NSKeyedArchiver archivedDataWithRootObject:_currentLoginData];
    }
    [data writeToFile:[self filepath] atomically:YES];
}


@end
