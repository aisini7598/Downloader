//
//  DYMDownloaderRequest.m
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DYMDownloaderRequest.h"
#import <AFNetworking/AFNetworking.h>

#import "AFNetworkServiceManager.h"

@interface DYMDownloaderRequest ()

@property (nonatomic) NSURLSessionDownloadTask *downloadTask;


@end

@implementation DYMDownloaderRequest

- (instancetype)init {
    self = [super init];
    if (self) {
            }
    return self;
}

- (void)main {
    if (self.downloadUrl.length > 0) {
        
        
        NSURLSessionDownloadTask *downloadTask = [[AFNetworkServiceManager sharedInstanced] dowoloadUrl:self.downloadUrl filePath:self.downloadFilePath progress:^(NSProgress *progress) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidRequest:progress:)]) {
                [self.delegate downloadDidRequest:self progress:progress];
            }
            
        } completedBlock:^(BOOL isFinished, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidFinished:)]) {
                [self.delegate downloadDidFinished:self];
            }
        }];
        
        [downloadTask resume];
        _downloadTask = downloadTask;
    }    
}

- (void)cancel {
    [_downloadTask suspend];
}

- (void)resume {
    [_downloadTask resume];
}

- (CGSize)fileSize {
    
    return CGSizeZero;
}

@end
