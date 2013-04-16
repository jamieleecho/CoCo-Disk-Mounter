//
//  JCConversionUtilsTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-24.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JCConversionUtilsTest.h"
#import "../../CoCo Disk Mounter/Delegate/JCConversionUtils.h"

@implementation JCConversionUtilsTest

- (void)testJCConvertStringToNSString {
    // Convert UTF8 bytes to NSString
    const unsigned char utf8Text[] = { 0x4a, 0x6f, 0x65, 0x27, 0x73, 0x20, 0x43, 0x61, 0x66, 0xc3, 0xa9, 0x20, 0x26, 0x20, 0x42, 0x61, 0x72, 0x20, 0xe2, 0x99, 0xab };
    NSString *str;
    @autoreleasepool {
        str = JCConvertStringToNSString((const char *)utf8Text);
        STAssertEqualObjects(@"Joe's Café & Bar ♫", str, @"JCConvertStringToNSString() failed to decode UTF8 C++ string");
        [str retain];
    }
    
    // Ensure that object is autoreleased
    NSUInteger retainCount = str.retainCount;
    [str release];
    STAssertEquals(retainCount, 1uL, @"JCConvertStringToNSString() not autoreleasing return value");
}

- (void)testJCConvertNSStringToString {
    std::string str1 = JCConvertNSStringToString(@"Joe's Café & Bar ♫");
    const unsigned char utf8Text[] = { 0x4a, 0x6f, 0x65, 0x27, 0x73, 0x20, 0x43, 0x61, 0x66, 0xc3, 0xa9, 0x20, 0x26, 0x20, 0x42, 0x61, 0x72, 0x20, 0xe2, 0x99, 0xab };
    const std::string str2((const char *)utf8Text);
    STAssertTrue(str1 == str2, @"JCConvertNSStringToString() failed to uncode UTF8 string.");
}

@end
