//
//  ConversionUtils.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-12.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#pragma once

#import <Cocoa/Cocoa.h>
#include <string>

/**
 * @param str UTF8 encoded C++ string
 * @return NSString version of str
 */
inline NSString *JCConvertStringToNSString(const std::string &str) {
    return [NSString stringWithUTF8String:str.c_str()];
}

/**
 * @param str NSString to convert
 * @return string version of str
 */
inline std::string JCConvertNSStringToString(NSString *str) {
    return std::string([str UTF8String]);
}
