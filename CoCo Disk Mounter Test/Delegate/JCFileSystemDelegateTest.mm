//
//  JCFileSystemDelegateTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-25.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JCFileSystemDelegateTest.h"
#import "../../CoCo Disk Mounter/Delegate/JCFileSystemDelegate.h"

@implementation JCFileSystemDelegateTest

- (void)testAttributeDictionaryFromMap {
    // Try adding only one entry
    std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> map;
    map[CoCoDiskMounter::IFileSystem::AttributeFileSize] = 1234;
    NSDictionary *dictionary;
    @autoreleasepool {
        dictionary = [JCFileSystemDelegate attributeDictionaryFromMap:map];
        STAssertEquals(1uL, dictionary.count, @"Attribute dictionary should have only one entry");
        STAssertEquals([NSNumber numberWithLong:1234], dictionary[NSFileSize], @"NSFileSize attribute entry must be 1234");
        [dictionary retain];
    }
    STAssertEquals(1ul, dictionary.retainCount, @"attributeDictionaryFromMap is not autoreleasing dictionary");
    
    // Try adding multiple entries
    map[CoCoDiskMounter::IFileSystem::AttributeFileType] = CoCoDiskMounter::IFileSystem::FileTypeDirectory;
    map[CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID] = 54321;
    map[CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID] = 321;
    map[CoCoDiskMounter::IFileSystem::AtributeFileModificationDate] = 1000;
    map[CoCoDiskMounter::IFileSystem::AttributePosixPermissions] = 0753;
    map[CoCoDiskMounter::IFileSystem::AttributeReferenceCount] = 10;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey] = 1001;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey] = 1002;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey] = 1003;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey] = 1004;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber] = 64;
    // next entry is bogus and should be ignored
    map[(CoCoDiskMounter::IFileSystem::Attribute_t)1000] = 643215;

    dictionary = [JCFileSystemDelegate attributeDictionaryFromMap:map];
    STAssertEquals(12uL, dictionary.count, @"Attribute dictionary should have 12 entries");
    STAssertEquals([NSNumber numberWithLong:1234], dictionary[NSFileSize], @"NSFileSize attribute entry must be 1234");
}

@end
