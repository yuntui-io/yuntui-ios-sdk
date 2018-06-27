//
//  DataManager.m
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import "DataManager.h"


@implementation NSArray(Map)
- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj)];
    }];
    return result;
}

@end

@implementation User
- (NSDictionary *)toDict {
    return @{
        @"userId": @(self.userId),
        @"appUserId": self.appUserId ?: @"",
        @"deviceId": self.deviceId,
        @"pushId": self.pushId ?: @"",
        @"sysProperties": self.sysProperties ?: @{},
        @"userProperties": self.userProperties ?: @{}
    };
}

+ (User *)fromDict:(NSDictionary *)dict {
    User *user = [[User alloc] init];
    user.userId = [[dict objectForKey:@"userId"] integerValue];
    user.appUserId = [dict objectForKey:@"appUserId"] ?: @"";
    user.deviceId = [dict objectForKey:@"deviceId"] ?: @"";
    user.pushId = [dict objectForKey:@"pushId"] ?: @"";
    user.sysProperties = [dict objectForKey:@"sysProperties"];
    user.userProperties =[dict objectForKey:@"userProperties"];
    return user;
}


@end

@implementation Event
- (NSDictionary *)toDict {
    return @{
        @"userId": @(self.userId),
        @"sessionId": self.sessionId,
        @"eventName": self.eventName,
        @"eventTime": self.eventTime,
        @"eventProperties": self.eventProperties
    };
}

+ (Event *)fromDict:(NSDictionary *)dict {
    Event *event = [[Event alloc] init];
    event.userId = [[dict objectForKey:@"userId"] integerValue];
    event.sessionId = [dict objectForKey:@"sessionId"] ?: @"";
    event.eventName = [dict objectForKey:@"eventName"] ?: @"";
    event.eventTime = [dict objectForKey:@"eventTime"] ?: @"";
    event.eventProperties =[dict objectForKey:@"eventProperties"];
    return event;
}
@end

@interface DataManager()
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *appKey;
@end

@implementation DataManager

- (instancetype)initWithAppKey:(NSString *)appKey {
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.events = [NSMutableArray array];
    }
    return self;
}


- (User *)currentUser {
    return self.user;
}

- (void)saveUser:(User *)user {
    self.user = user;
}

- (void)saveEvent:(Event *)event {
    [self.events addObject:event];
}

- (NSArray *)popAllEvents {
    NSArray *events = [NSArray arrayWithArray:self.events];
    self.events = [NSMutableArray array];
    return events;
}

- (NSURL *)getDataFileURL {
    NSMutableString *reversedAppKey = [NSMutableString stringWithCapacity:[self.appKey length]];
    
    [self.appKey enumerateSubstringsInRange:NSMakeRange(0,[self.appKey length])
                                 options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                  [reversedAppKey appendString:substring];
                              }];
    NSString *fileName = [NSString stringWithFormat:@"yuntui-%@", reversedAppKey];
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    return [documentsURL URLByAppendingPathComponent:fileName];
}

- (void)loadDataFromFile {
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:[self getDataFileURL]];
    NSDictionary *userDict = [data objectForKey:@"user"];
    if (userDict) {
        self.user = [User fromDict:userDict];
    } else {
        self.user = [[User alloc] init];
    }
    NSArray *events = [data objectForKey:@"events"];
    if (events) {
        self.events = [[events map:^id(id obj) {
            return [Event fromDict:obj];
        }] mutableCopy];
    }
}

- (void)persistDataToFile {
    NSDictionary *data = @{
        @"user": [self.user toDict],
        @"events": [self.events map:^id(id obj) { return [obj toDict]; }]
    };
    [data writeToURL:[self getDataFileURL] atomically:YES];
}
@end
