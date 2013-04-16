//
//  FileSystemTest.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "FileSystemTest.h"
#include "MockDiskImage.h"
#include "../../CoCo Disk Mounter/Model/FileSystem.h"

@implementation FileSystemTest

- (void)testRemembersDiskImage {
    std::shared_ptr<CoCoDiskMounterTest::MockDiskImage> diskImage(new CoCoDiskMounterTest::MockDiskImage());
    CoCoDiskMounter::FileSystem target(diskImage);
    STAssertEquals(2l, diskImage.use_count());
}

@end
