//
//  DataManager.h
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray(Map)
- (NSArray *)map:(id (^)(id obj))block;
@end

@interface User: NSObject
@property (nonatomic) NSInteger userId;
@property (nonatomic, copy) NSString *appUserId;
@property (nonatomic, copy) NSString *pushId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, strong) NSDictionary *sysProperties;
@property (nonatomic, strong) NSDictionary *userProperties;
- (NSDictionary *)toDict;
+ (User *)fromDict:(NSDictionary *)dict;
@end

@interface Event: NSObject
@property (nonatomic) NSInteger userId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *eventTime;
@property (nonatomic, strong) NSMutableDictionary *eventProperties;
- (NSDictionary *)toDict;
+ (Event *)fromDict:(NSDictionary *)dict;
@end

@interface DataManager : NSObject
@property (nonatomic, strong) NSMutableArray *events;
- (instancetype)initWithAppKey:(NSString *)appKey;
- (User *)currentUser;
- (void)saveUser:(User *)user;
- (void)saveEvent:(Event *)event;
- (NSArray *)popAllEvents;
- (void)loadDataFromFile;
- (void)persistDataToFile;
@end
