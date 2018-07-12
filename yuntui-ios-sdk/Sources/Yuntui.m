//
//  Yuntui.m
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Yuntui.h"
#import "DataManager.h"
#import "Network.h"

@interface Yuntui()
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, strong) Network *network;
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSDictionary *pushPayload;
@property (nonatomic, copy) NSString *sessionId;
@end

@implementation Yuntui
+ (Yuntui *)shared {
    static Yuntui *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)setupWithAppKey:(NSString *)appKey {
    self.appKey = appKey;
    self.network = [[Network alloc] initWithAppKey:appKey];
    self.dataManager = [[DataManager alloc] initWithAppKey:appKey];
    
    [self.dataManager loadDataFromFile];
    [self.dataManager currentUser].sysProperties = @{
        @"platform": @"ios",
        @"osVersion": [[UIDevice currentDevice] systemVersion],
        @"bundleId": [[NSBundle mainBundle] bundleIdentifier],
        @"appVersion": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
    };
    [self.dataManager currentUser].deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if ([self.dataManager currentUser].userId == 0) {
        [self createUser];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForegroud:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [self handleEnteredForegroud:nil];
}


- (void)setAppUserId:(NSString *)appUserId {
    [self.dataManager currentUser].appUserId = appUserId;
}

- (void)setPushId:(NSString *)pushId {
    [self.dataManager currentUser].pushId = pushId;
    [self updateUser];
}

- (void)setUserProperties:(NSDictionary *)properties {
    [self.dataManager currentUser].userProperties = properties;
}

- (void)handleNotificationUserInfo:(NSDictionary *)userInfo {
    NSDictionary *pushPayload = userInfo[@"@yuntui"];
    if (!pushPayload) {
        return;
    }
    self.pushPayload = pushPayload;
    for(Event *event in self.dataManager.events) {
        if ([event.sessionId isEqualToString:self.sessionId]) {
            [event.eventProperties addEntriesFromDictionary:pushPayload];
        }
    }
}

- (void)logEvent:(NSString *)name {
    [self logEvent:name properties:nil];
}

- (void)logEvent:(NSString *)name properties:(NSDictionary *)properties {
    Event *event = [[Event alloc] init];
    event.eventName = name;
    event.userId = self.dataManager.currentUser.userId;
    event.sessionId = self.sessionId;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    event.eventTime = [formatter stringFromDate:[NSDate date]];
    
    event.eventProperties = [NSMutableDictionary dictionary];
    if (properties) {
        [event.eventProperties addEntriesFromDictionary:properties];
    }
    if (self.pushPayload) {
        [event.eventProperties addEntriesFromDictionary:self.pushPayload];
    }
    [self.dataManager saveEvent:event];
    
    if (self.dataManager.events.count > 50) {
        [self pushEvents];
    }
}

- (void)handleEnteredForegroud:(NSNotification *)notification {
    self.sessionId = [[NSUUID UUID] UUIDString];
    [self logEvent:@"@open_app"];
}

- (void)handleEnteredBackground:(NSNotification *)notification {
    [self logEvent:@"@close_app"];
    [self.dataManager persistDataToFile];
    [self updateUser];
    [self pushEvents];
    self.pushPayload = nil;
}

- (void)createUser {
    User *user = [self.dataManager currentUser];
    if (user.userId != 0) {
        return;
    }
    [self.network postToPath:@"/api/v1/user/create" data:[user toDict] onSuccess:^(id data) {
        NSLog(@"create user success");
        NSInteger userId = [data integerValue];
        [self.dataManager currentUser].userId = userId;
        for(Event *event in self.dataManager.events) {
            event.userId = userId;
        }
    } onFailure:^(NSString *msg) {
        NSLog(@"create user fail");
    }];
}

- (void)updateUser {
    User *user = [self.dataManager currentUser];
    if (user.userId == 0) {
        return;
    }
    [self.network postToPath:@"/api/v1/user/update" data:[user toDict] onSuccess:^(id data) {
        NSLog(@"update user success");
    } onFailure:^(NSString *msg) {
        NSLog(@"update user failed %@: ", msg);
    }];
}


- (void)pushEvents {
    User *user = [self.dataManager currentUser];
    if (user.userId == 0) {
        return;
    }
    NSArray *events = [self.dataManager popAllEvents];
    if (events.count == 0) {
        return;
    }
    NSArray *body = [events map:^id(id obj) {
        return [obj toDict];
    }];
    [self.network postToPath:@"/api/v1/event/create" data:body onSuccess:^(id data) {
        NSLog(@"push events succeeded");

        [self.dataManager persistDataToFile];
    } onFailure:^(NSString *msg) {
        NSLog(@"push events failed: %@", msg);
        [self.dataManager.events addObjectsFromArray:events];
        [self.dataManager persistDataToFile];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
