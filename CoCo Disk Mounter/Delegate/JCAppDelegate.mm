//
//  JCAppDelegate.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-28.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#include <memory>

#import "JCAppDelegate.h"
#import "JCFileSystemDelegate.h"
#include "RsDosFileSystem.h"
#include "JVCDiskImage.h"

@implementation JCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    std::shared_ptr<CoCoDiskMounter::DiskImage> diskImage(new CoCoDiskMounter::JVCDiskImage("/Users/jcho/Desktop/SGU5.dsk"));
    std::shared_ptr<CoCoDiskMounter::IFileSystem> fileSystem(new CoCoDiskMounter::RsDosFileSystem(diskImage));
    JCFileSystemDelegate *rsdosDelegate = [[JCFileSystemDelegate alloc] initWithFileSystem:fileSystem];
    filesystem = [[GMUserFileSystem alloc] initWithDelegate:rsdosDelegate isThreadSafe:NO];
    [filesystem mountAtPath:@"/Volumes/SGU5" withOptions:[NSArray array]];

    std::shared_ptr<CoCoDiskMounter::DiskImage> diskImage2(new CoCoDiskMounter::JVCDiskImage("/Users/jcho/Desktop/Breakout.dsk"));
    std::shared_ptr<CoCoDiskMounter::IFileSystem> fileSystem2(new CoCoDiskMounter::RsDosFileSystem(diskImage2));
    JCFileSystemDelegate *rsdosDelegate2 = [[JCFileSystemDelegate alloc] initWithFileSystem:fileSystem2];
    filesystem = [[GMUserFileSystem alloc] initWithDelegate:rsdosDelegate2 isThreadSafe:NO];
    [filesystem mountAtPath:@"/Volumes/Breakout" withOptions:[NSArray array]];
}

@end
