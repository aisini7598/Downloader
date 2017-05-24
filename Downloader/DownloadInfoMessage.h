//
//  DownloadInfoMessage.h
//  Downloader
//
//  Created by John on 2017/5/24.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DownloadInfoMessage : NSObject

@property (nonatomic, copy) NSString *indentifire;
@property (nonatomic) int64_t fileSize;
@property (nonatomic) int64_t currentSize;
@property (nonatomic, copy) NSString *downloadUrl;

@property (nonatomic) BOOL isFinished;

@property (nonatomic) BOOL isPause;

- (NSDictionary *)revertToDictionary;
+ (instancetype)initWithDictionay:(NSDictionary *)dictionary;

@end
