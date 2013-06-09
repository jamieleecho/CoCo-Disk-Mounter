//
//  JVCDiskImageTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JVCDiskImageTest.h"

#include <string>

#include "../../CoCo Disk Mounter/Delegate/JCConversionUtils.h"

@implementation JVCDiskImageTest

static std::string openResource(NSString *str) {
    NSBundle *bundle = [NSBundle bundleForClass:[JVCDiskImageTest class]];
    return JCConvertNSStringToString([bundle pathForResource:str ofType:@"dsk"]);
}



@end
