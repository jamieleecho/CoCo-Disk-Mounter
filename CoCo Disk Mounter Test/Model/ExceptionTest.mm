//
//  ExceptionTest.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-23.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "ExceptionTest.h"

#include "../../CoCo Disk Mounter/Model/Exception.h"

@implementation ExceptionTest

#define testSimpleException(T) \
    T target1; \
    STAssertTrue("" == target1.getReason(), @"Reason should be blank."); \
    T target2("Oops!"); \
    STAssertTrue("Oops!" == target2.getReason(), @"Reason should be Oops!");

#define testFilenameException(T, message) \
    T target1; \
    STAssertTrue(" "  message == target1.getReason(), @"Reason should be " @message);     STAssertTrue(target1.getFilename() == "", @"Filename should be an empty string"); \
    T target2("File.wav"); \
    STAssertTrue("File.wav " message == target2.getReason(), @"Reason should be File.wav " @message); \
    STAssertTrue(target2.getFilename() == "File.wav", @"Filename should be File.wav");

- (void)testException {
    testSimpleException(CoCoDiskMounter::Exception);
}

- (void)testIOException {
    testSimpleException(CoCoDiskMounter::IOException);
}

- (void)testFileNotFoundException {
    testFilenameException(CoCoDiskMounter::FileNotFoundException, "could not be found");
}

- (void)testFilePermissionException {
    testFilenameException(CoCoDiskMounter::FilePermissionException, "could not be accessed");
}

- (void)testBadFileFormatException {
    testFilenameException(CoCoDiskMounter::BadFileFormatException, "has an unknown file type");
}

- (void)testNotADirectoryException {
    testFilenameException(CoCoDiskMounter::NotADirectoryException, "is not a directory");
}

- (void)testNotAFileException {
    testFilenameException(CoCoDiskMounter::NotAFileException, "is not a file");
}
@end
