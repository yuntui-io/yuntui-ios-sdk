//
//  Yuntui.h
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yuntui: NSObject
+ (id)shared;
- (void)setupWithAppKey:(NSString *)appKey;
- (void)setAppUserId:(NSString *)appUserId;
- (void)setPushId:(NSString *)pushId;
- (void)setUserProperties:(NSDictionary *)properties;
- (void)handleNotificationUserInfo:(NSDictionary *)userInfo;
- (void)logEvent:(NSString *)name;
- (void)logEvent:(NSString *)name properties:(NSDictionary *)properties;
@end
