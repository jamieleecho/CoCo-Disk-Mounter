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
    map[CoCoDiskMounter::IFileSystem::AtributeFileModificationDate] = 1005;
    map[CoCoDiskMounter::IFileSystem::AttributePosixPermissions] = 0753;
    map[CoCoDiskMounter::IFileSystem::AttributeReferenceCount] = 10;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey] = 1001;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey] = 1002;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey] = 1003;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey] = 1004;
    map[CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber] = 64;
    // next entry is bogus and should be ignored
    map[(CoCoDiskMounter::IFileSystem::Attribute_t)1000] = 643215;

    // Check entries
    @autoreleasepool {
        dictionary = [JCFileSystemDelegate attributeDictionaryFromMap:map];
        [dictionary retain];
        STAssertEquals(12uL, dictionary.count, @"Attribute dictionary should have 12 entries");
        STAssertEquals([NSNumber numberWithLong:1234], dictionary[NSFileSize], @"NSFileSize attribute entry must be 1234");
        STAssertEquals(NSFileTypeDirectory, dictionary[NSFileType], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeFileType");
        STAssertEqualObjects([NSNumber numberWithLong:54321], dictionary[NSFileGroupOwnerAccountID], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID");
        STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1005/1000.0], dictionary[NSFileModificationDate], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeFileModificationDate");
        STAssertEqualObjects([NSNumber numberWithLong:321], dictionary[NSFileOwnerAccountID], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributePosixPermissions");
        STAssertEqualObjects([NSNumber numberWithLong:0753], dictionary[NSFilePosixPermissions], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID");
        STAssertEqualObjects([NSNumber numberWithLong:10], dictionary[NSFileReferenceCount], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeReferenceCount");
        STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1001/1000.0], dictionary[kGMUserFileSystemFileAccessDateKey], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey");
        STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1002/1000.0], dictionary[kGMUserFileSystemFileBackupDateKey], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey");
        STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1003/1000.0], dictionary[kGMUserFileSystemFileChangeDateKey], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey");
        STAssertEqualObjects([NSNumber numberWithLong:1004], dictionary[kGMUserFileSystemFileFlagsKey], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey");
        STAssertEqualObjects([NSNumber numberWithLong:64], dictionary[NSFileSystemFileNumber], @"attributeDictionaryFromMap is not properly mapping CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber");
    }
    STAssertEquals(1ul, dictionary.retainCount, @"dictionary not autoreleased");
    [dictionary release];
}

- (void) testDictionaryAttributeFromMapAttribute {
    STAssertEqualObjects(NSFileType, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeFileType], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeFileType");
    STAssertEqualObjects(NSFileSize, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeFileSize], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeFileSize");
    STAssertEqualObjects(NSFileModificationDate, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AtributeFileModificationDate], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AtributeFileModificationDate");
    STAssertEqualObjects(NSFileReferenceCount, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeReferenceCount], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeReferenceCount");
    STAssertEqualObjects(NSFilePosixPermissions, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributePosixPermissions], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributePosixPermissions");
    STAssertEqualObjects(NSFileOwnerAccountID, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID");
    STAssertEqualObjects(NSFileGroupOwnerAccountID, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID");
    STAssertEqualObjects(NSFileSystemFileNumber, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber");
    STAssertEqualObjects(kGMUserFileSystemFileBackupDateKey, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey");
    STAssertEqualObjects(kGMUserFileSystemFileChangeDateKey, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey");
    STAssertEqualObjects(kGMUserFileSystemFileAccessDateKey, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey");
    STAssertEqualObjects(kGMUserFileSystemFileFlagsKey, [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey], @"dictionaryAttributeFromMapAttribute does not properly map CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey");
    STAssertNil([JCFileSystemDelegate dictionaryAttributeFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)10000], @"dictionaryAttributeFromMapAttribute does not properly map invalid attributes");
}

@end
