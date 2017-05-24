//
//  DownloadInfoMessage.m
//  Downloader
//
//  Created by John on 2017/5/24.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DownloadInfoMessage.h"
#import <YYModel/YYModel.h>
#import "DownloadUnitTool.h"

@implementation DownloadInfoMessage

- (NSString *)indentifire {
    return [DownloadUnitTool stringFromMD5:self.downloadUrl];
}

- (NSDictionary *)revertToDictionary {
    return [self yy_modelToJSONObject];
}

+ (instancetype)initWithDictionay:(NSDictionary *)dictionary {
    return [DownloadInfoMessage yy_modelWithDictionary:dictionary];
}

@end
