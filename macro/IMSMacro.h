//
//  IMSMacro.h
//  StarMaker
//
//  Created by yuhao on 2021/3/15.
//  Copyright © 2021 uShow. All rights reserved.
//
#import <foundation/Foundation.h>
#ifndef IMSMacro_h
#define IMSMacro_h

//string是否为空、空对象。。。
#define NULLString(string) ((![string isKindOfClass:[NSString class]]) || [string isEqualToString:@""] || (string == nil) || [string isEqualToString:@""] || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])

#define NonNULLString(string) (NULLString(string) ? @"" : string)

#define weakify(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define strongify(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#endif /* IMSMacro_h */
