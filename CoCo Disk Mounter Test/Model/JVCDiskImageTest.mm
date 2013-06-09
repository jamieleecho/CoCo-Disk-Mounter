//
//  JVCDiskImageTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JVCDiskImageTest.h"

#include <string>
#include <stdio.h>
#include <iostream>

#include "../../CoCo Disk Mounter/Delegate/JCConversionUtils.h"
#include "../../CoCo Disk Mounter/Model/JVCDiskImage.h"

using namespace CoCoDiskMounter;

@implementation JVCDiskImageTest

static std::string getPathForDiskFileResource(NSString *str) {
    NSBundle *bundle = [NSBundle bundleForClass:[JVCDiskImageTest class]];
    NSString *path = [bundle pathForResource:str ofType:@"dsk"];
    return JCConvertNSStringToString(path);
}


static std::string copyDiskFileResourceToTempFile(NSString *str) {
    NSBundle *bundle = [NSBundle bundleForClass:[JVCDiskImageTest class]];
    NSString *srcPath = [bundle pathForResource:str ofType:@"dsk"];
    char *dstName = tmpnam(NULL);
    NSString *dstPath = JCConvertStringToNSString(dstName);
    [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];
    return dstName;
}


- (void)testConstructorThrowsRightExceptions {
    // Open a file that does not exist
    try {
        JVCDiskImage target("/Systems/Windows/Breakout.dsk");
        STFail(@"Should have thrown FileNotFoundException");
    } catch(const FileNotFoundException &fnfe) {
    }
    
    // Try to open an unreadable copy of the disk image
    std::string fileCopy = copyDiskFileResourceToTempFile(@"Breakout");
    NSDictionary *noAccessAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0] forKey:NSFilePosixPermissions];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager setAttributes:noAccessAttributes ofItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
    {
        try {
            JVCDiskImage target(fileCopy.c_str());
            STFail(@"Should have thrown FilePermissionException");
        } catch(const FilePermissionException &fpe) {
        }
    }
    
    // Opening a file with a strange size should fail
    NSDictionary *allAccessAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0777] forKey:NSFilePosixPermissions];
    [fileManager setAttributes:allAccessAttributes ofItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
    {
        std::ofstream fout(fileCopy.c_str(), std::ios::out | std::ios::binary);
        fout.write("a", 1);
        fout.close();
        try {
            JVCDiskImage target(fileCopy.c_str());
            STFail(@"Should have thrown BadFileFormatException");
        } catch(const BadFileFormatException &bfe) {
        }
    }
    
    // Opening an empty file should fail
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
    {
        std::ofstream fout(fileCopy.c_str(), std::ios::out | std::ios::binary);
        fout.close();
        try {
            JVCDiskImage target(fileCopy.c_str());
            STFail(@"Should have thrown BadFileFormatException");
        } catch(const BadFileFormatException &bfe) {
        }
    }

    // Clean up
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
}


- (void)testCanRead {
    // Read characters into buffer
    JVCDiskImage target(getPathForDiskFileResource(@"Breakout").c_str());
    unsigned char buffer[1024];
    for(int ii=0; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
        buffer[ii] = 'C';
    STAssertEquals(target.read(buffer, 100, 123, 17, 2), 123, @"Did not return expected number of read characters");

    // Spot check buffer
    
    
    // Make sure we did not overrun
    for(int ii=0; ii<100; ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
    for(int ii=223; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
}


- (void)testCanReadOverBoundaryLimits {
    JVCDiskImage target(getPathForDiskFileResource(@"Breakout").c_str());
}


- (void)testCanWrite {
    std::string fileCopy = copyDiskFileResourceToTempFile(@"Breakout");
    JVCDiskImage target(fileCopy.c_str());

    // Clean up
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
}


- (void)testCanWriteOverBoundaryLimits {
    std::string fileCopy = copyDiskFileResourceToTempFile(@"Breakout");
    JVCDiskImage target(fileCopy.c_str());

    // Clean up
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
}

@end
