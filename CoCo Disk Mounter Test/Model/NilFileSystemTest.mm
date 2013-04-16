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
    STAssertTrue(contents.empty(), 0L, @"NilFileSystem::contentsOfDirectoryPath should do nothing");
    STAssertEquals(target.getSize(), 0L, @"NilFileSystem::getSize() should return 0");
    STAssertEquals(target.getFreeSpace(), 0L, @"NilFileSystem::getFreeSpace() should return 0");
    STAssertEquals(target.getNodes(), 0L, @"NilFileSystem::getNodes() should return 0");
    STAssertEquals(target.getFreeNodes(), 0L, @"NilFileSystem::getFreeNodes() should return 0");
    STAssertNil((id)target.openFileAtPath("/sdfsdf/sdfsdf", CoCoDiskMounter::IFileSystem::FileOpenModeReadOnly), @"NilFileSystem::openFileAtPath() should return NULL");
    target.closeFile(NULL);

    char buffer[] = "hello";
    STAssertEquals(target.readFile(NULL, buffer, 100, 0), (size_t)0, @"NilFileSystem::readFile() should return 0");
    STAssertEquals(strcmp("hello", buffer), 0, @"NilFileSystem::readFile() should not change buffer");
    
    std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> attributes;
    target.getPropertiesOfFile(attributes, "/foo/bar");
    STAssertTrue(attributes.empty(), @"NilFileSystem::getPropertiesOfFile should do nothing");
}

@end
