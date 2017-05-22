//
//  DYMDownloaderRequest.m
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DYMDownloaderRequest.h"
#import <AFNetworking/AFNetworking.h>

@interface DYMDownloaderRequest ()
@property (nonatomic) AFHTTPSessionManager *downloadManager;
@end

@implementation DYMDownloaderRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        AFHTTPSessionManager *downloadManager = [[AFHTTPSessionManager alloc] init];
        AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
        requestSerializer.timeoutInterval = 60;
        downloadManager.requestSerializer = requestSerializer;
        downloadManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _downloadManager = downloadManager;
    }
    return self;
}

- (void)main {
    [super main];
    
    if (self.downloadUrl.length > 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        
        [_downloadManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            
            return [NSURL fileURLWithPath:self.downloadFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
        }];
    }
    
}

@end
