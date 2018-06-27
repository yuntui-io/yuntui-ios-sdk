//
//  Network.h
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject
- (instancetype)initWithAppKey:(NSString *)appKey;
- (void)postToPath:(NSString *)path data:(id)data onSuccess:(void (^)(id data))successHandler onFailure:(void (^)(NSString *msg))failureHandler;
@end
