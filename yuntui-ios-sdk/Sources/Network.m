//
//  Network.m
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/25.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import "Network.h"
@interface Network()
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation Network

- (instancetype)initWithAppKey:(NSString *)appKey {
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}


- (void)postToPath:(NSString *)path data:(id)data onSuccess:(void (^)(id data))successHandler onFailure:(void (^)(NSString *msg))failureHandler {
    NSString *serverHost = @"https://autopushapi.bxapp.cn";
    NSString *urlString = [serverHost stringByAppendingString:path];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    [request addValue:self.appKey forHTTPHeaderField:@"X-AppKey"];
    [request addValue:@"ios@0.0.1" forHTTPHeaderField:@"X-YutuiSDKVersion"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return failureHandler([NSString stringWithFormat:@"api error: %@", [error description]]);
        }
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        if (resp.statusCode != 200) {
            return failureHandler(@"api error: status != 200");
        }
        if (!data) {
            return failureHandler(@"api error: no data");
        }
        NSError *e;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        if (e) {
            return failureHandler(@"api error: json parse error");
        }
        NSInteger code = [[json objectForKey:@"code"] integerValue];
        if (code != 200) {
            return failureHandler(@"api error: code != 00");
        }
        return successHandler([json objectForKey:@"data"]);
    }];
    
    [dataTask resume];

}

@end
