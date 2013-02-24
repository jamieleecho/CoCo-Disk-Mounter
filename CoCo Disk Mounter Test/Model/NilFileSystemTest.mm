//
//  NilFileSystemTest.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-24.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "NilFileSystemTest.h"

#include "../../CoCo Disk Mounter/Model/NilFileSystem.h"

@implementation NilFileSystemTest

- (void)testDoesBasicallyNothing {
    CoCoDiskMounter::NilFileSystem target;
    std::vector<std::string> contents;
    target.contentsOfDirectoryAtPath(contents, "/sdfsdf/sdfsdf/sdfsdf");
    STAssertTrue(contents.empty(), @"NilFileSystem::contentsOfDirectoryPath should do nothing");
    STAssertEquals(0L, target.getSize(), @"NilFileSystem::getSize() should return 0");
    STAssertEquals(0L, target.getFreeSpace(), @"NilFileSystem::getFreeSpace() should return 0");
    STAssertEquals(0L, target.getNodes(), @"NilFileSystem::getNodes() should return 0");
    STAssertEquals(0L, target.getFreeNodes(), @"NilFileSystem::getFreeNodes() should return 0");
    STAssertNil((id)target.openFileAtPath("/sdfsdf/sdfsdf", CoCoDiskMounter::IFileSystem::FileOpenModeReadOnly), @"NilFileSystem::openFileAtPath() should return NULL");
    target.closeFile(NULL);

    char buffer[] = "hello";
    STAssertEquals((size_t)0, target.readFile(NULL, buffer, 100, 0), @"NilFileSystem::readFile() should return 0");
    STAssertEquals(0, strcmp("hello", buffer), @"NilFileSystem::readFile() should not change buffer");
    
    std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> attributes;
    target.getPropertiesOfFile(attributes, "/foo/bar");
    STAssertTrue(attributes.empty(), @"NilFileSystem::getPropertiesOfFile should do nothing");
}

@end
