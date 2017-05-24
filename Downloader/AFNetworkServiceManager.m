//
//  AFNetSeriviceManager.m
//  Downloader
//
//  Created by John on 2017/5/24.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "AFNetworkServiceManager.h"
#import <AFNetworking/AFNetworking.h>

@interface AFNetworkServiceManager ()

@property (nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation AFNetworkServiceManager

+ (instancetype)sharedInstanced {
    static AFNetworkServiceManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[AFNetworkServiceManager alloc] init];
        
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"dymbackgroudtask"]];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (NSURLSessionDownloadTask *)dowoloadUrl:(NSString *)url filePath:(NSString *)filePath progress:(void (^)(NSProgress *))progress completedBlock:(void (^)(BOOL,NSError *))completedBlcok {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        completedBlcok(YES, error);
    }];
    return task;
}

@end
