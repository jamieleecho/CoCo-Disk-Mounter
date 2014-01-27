//
//  JVCDiskImageTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JVCDiskImageTest.h"
#import <CoreFoundation/CoreFoundation.h>

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
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    
    NSString *dstPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uuidString];
    [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];

    [uuidString release];
    CFRelease(uuidRef);

    return JCConvertNSStringToString(dstPath);
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
    STAssertEquals(target.read(buffer, 100, 171, 17, 2, 32), 171, @"Did not return expected number of read characters");

    // Spot check buffer
    STAssertEquals(strncmp((char *)buffer + 100, "BALLOON BIN", 11), 0, @"First few bytes should have been BALLOON");
    STAssertEquals(strncmp((char *)buffer + 260, "BREAKOUTBAS", 11), 0, @"Last few bytes should have been BREAKOUTBAS");
    
    // Make sure we did not overrun
    for(int ii=0; ii<100; ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
    for(int ii=271; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
}


- (void)testCanReadOverBoundaryLimits {
    // Read characters into buffer
    JVCDiskImage target(getPathForDiskFileResource(@"Breakout").c_str());
    unsigned char buffer[13824];
    for(int ii=0; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
        buffer[ii] = 'C';
    STAssertEquals(target.read(buffer, 100, sizeof(buffer)/sizeof(buffer[00]) - 100, 33, 6, 112), 7568, @"Did not return expected number of read characters");
    
    // Spot check buffer
    STAssertEquals(strncmp((char *)buffer + 100, "ART", 3), 0, @"First few bytes should have been ART");
    STAssertEquals(buffer[7568 + 99], (unsigned char)0xff, @"Last byte should have been 0xff");
    
    // Make sure we did not overrun
    for(int ii=0; ii<100; ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
    for(int ii=7668; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
        STAssertEquals((char)buffer[ii], 'C', @"Buffer overrun detected");
}


- (void)testCanWrite {
    std::string fileCopy = copyDiskFileResourceToTempFile(@"Breakout");
    {
        JVCDiskImage target(fileCopy.c_str());
        STAssertEquals(target.write((unsigned char *)"hello world", 0, 11, 17, 2, 32), 11, @"Failed to write 11 characters");
    }
    {
        JVCDiskImage target(fileCopy.c_str());
        unsigned char buffer[1024];
        for(int ii=0; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
            buffer[ii] = 'C';
        STAssertEquals(target.read(buffer, 0, 11, 17, 2, 32), 11, @"Did not return expected number of read characters");
        STAssertEquals(strncmp((char *)buffer, "hello world", 11), 0, @"Failed to write hello world");
    }

    // Clean up
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
}


- (void)testCanWriteOverBoundaryLimits {
    std::string fileCopy = copyDiskFileResourceToTempFile(@"Breakout");
    {
        JVCDiskImage target(fileCopy.c_str());
        STAssertEquals(target.write((unsigned char *)"hello world", 0, 11, 34, 17, 251), 5, @"Failed to write 5 characters");
    }
    {
        JVCDiskImage target(fileCopy.c_str());
        unsigned char buffer[1024];
        for(int ii=0; ii<sizeof(buffer)/sizeof(buffer[0]); ii++)
            buffer[ii] = 'C';
        STAssertEquals(target.read(buffer, 0, 5, 34, 17, 251), 5, @"Did not return expected number of read characters");
        STAssertEquals(strncmp((char *)buffer, "hello", 5), 0, @"Failed to write hello   ");
    }

    // Clean up
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:JCConvertStringToNSString(fileCopy) error:nil];
}

@end
