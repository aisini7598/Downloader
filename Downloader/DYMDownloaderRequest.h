//
//  DYMDownloaderRequest.h
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DYMDownloaderRequest;

@protocol DYMDownloaderRequestDelegate <NSObject>

- (void)downloadDidRequest:(DYMDownloaderRequest *)request progress:(NSProgress *)progress;

- (void)downloadDidFinished:(DYMDownloaderRequest *)request;

@end

@interface DYMDownloaderRequest : NSOperation

@property (nonatomic, weak) id<DYMDownloaderRequestDelegate> delegate;

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *downloadFilePath;
@property (nonatomic, copy) NSString *indentifire;

- (void)cancel;

- (void)resume;

@end
