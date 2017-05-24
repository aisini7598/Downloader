
//
//  DownloadUnitTool.m
//  Downloader
//
//  Created by John on 2017/5/24.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DownloadUnitTool.h"
#import <CommonCrypto/CommonDigest.h>


@implementation DownloadUnitTool

+ (NSString *)stringFromMD5:(NSString *)str {
    if(str == nil || [str length] == 0) {
        return nil;
    }
    const char *value = [str UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

@end
