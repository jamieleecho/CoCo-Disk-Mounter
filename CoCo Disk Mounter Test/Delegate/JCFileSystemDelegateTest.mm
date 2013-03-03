//
//  JCFileSystemDelegateTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-25.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JCFileSystemDelegateTest.h"

#import "../../CoCo Disk Mounter/Delegate/JCFileSystemDelegate.h"
#include "gmock/gmock.h"

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

- (void)testDictionaryAttributeFromMapAttribute {
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

- (void)testDictionaryAttributeValueFromMapAttribute {
    STAssertEqualObjects(NSFileTypeRegular, [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeFileType mapValue:CoCoDiskMounter::IFileSystem::FileTypeRegular], @"dictionaryAttributeValueFromMapAttribute does not properly map file types");
    STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1001/1000.0], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AtributeFileModificationDate mapValue:1001], @"dictionaryAttributeValueFromMapAttribute does not properly map modified dates");
    STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1002/1000.0], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey mapValue:1002], @"dictionaryAttributeValueFromMapAttribute does not properly map backup dates");
    STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1003/1000.0], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey mapValue:1003], @"dictionaryAttributeValueFromMapAttribute does not properly map change dates");
    STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)1004/1000.0], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey mapValue:1004], @"dictionaryAttributeValueFromMapAttribute does not properly map file access dates");
    STAssertEqualObjects([NSNumber numberWithLong:12345], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeFileSize mapValue:12345], @"dictionaryAttributeValueFromMapAttribute does not properly map file size");
    STAssertEqualObjects([NSNumber numberWithLong:1234], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeFileSize mapValue:1234], @"dictionaryAttributeValueFromMapAttribute does not properly map file size");
    STAssertEqualObjects([NSNumber numberWithLong:123], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributePosixPermissions mapValue:123], @"dictionaryAttributeValueFromMapAttribute does not properly map posix permissions");
    STAssertEqualObjects([NSNumber numberWithLong:12], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID mapValue:12], @"dictionaryAttributeValueFromMapAttribute does not properly map account id");
    STAssertEqualObjects([NSNumber numberWithLong:54321], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID mapValue:54321], @"dictionaryAttributeValueFromMapAttribute does not properly map group account id");
    STAssertEqualObjects([NSNumber numberWithLong:5432], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey mapValue:5432], @"dictionaryAttributeValueFromMapAttribute does not properly map group flags");
    STAssertEqualObjects([NSNumber numberWithLong:5432], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber mapValue:5432], @"dictionaryAttributeValueFromMapAttribute does not properly map file number");
    STAssertEqualObjects([NSNumber numberWithLong:543], [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)1000 mapValue:543], @"dictionaryAttributeValueFromMapAttribute does not properly map invalid keys");
}

- (void)testDictionaryFileTypeFromMapFileType {
    STAssertEqualObjects(NSFileTypeRegular, [JCFileSystemDelegate dictionaryFileTypeFromMapFileType:CoCoDiskMounter::IFileSystem::FileTypeRegular], @"dictionaryFileTypeFromMapFileType does not properly map FileTypeRegular");
    STAssertEqualObjects(NSFileTypeDirectory, [JCFileSystemDelegate dictionaryFileTypeFromMapFileType:CoCoDiskMounter::IFileSystem::FileTypeDirectory], @"dictionaryFileTypeFromMapFileType does not properly map FileTypeDirectory");
    STAssertEqualObjects(NSFileTypeSymbolicLink, [JCFileSystemDelegate dictionaryFileTypeFromMapFileType:CoCoDiskMounter::IFileSystem::FileTypeSymbolicLink], @"dictionaryFileTypeFromMapFileType does not properly map FileTypeSymbolicLink");
    STAssertEqualObjects(NSFileTypeUnknown, [JCFileSystemDelegate dictionaryFileTypeFromMapFileType:(CoCoDiskMounter::IFileSystem::FileType_t)100], @"dictionaryFileTypeFromMapFileType does not properly map invalid attributes");
    
}

- (void)testFileOpenModeFromOpenMode {
    STAssertEquals(CoCoDiskMounter::IFileSystem::FileOpenModeReadOnly, [JCFileSystemDelegate fileOpenModeFromOpenMode:O_RDONLY], @"fileOpenModeFromOpenMode does not properly map fileOpenModeFromOpenMode");
    try {
        [JCFileSystemDelegate fileOpenModeFromOpenMode:O_RDWR];
        STFail(@"fileOpenModeFromOpenMode should only convert");
    } catch(CoCoDiskMounter::IOException &ioe) {        
    }
}

- (void)testNilFileSystemUsedByDefaultInitializer {
    JCFileSystemDelegate *target = [[[JCFileSystemDelegate alloc] init] autorelease];
    NSError *error = nil;
    id userData = nil;
    STAssertEquals(0uL, [[target contentsOfDirectoryAtPath:@"/" error:&error] count], @"should return no directory entries");
    STAssertNil(error, @"contentsOfDirectoryAtPath:error should return no error");
    std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> mapAttributes;
    STAssertEquals(0uL, [[target attributesOfItemAtPath:@"/" userData:nil error:&error] count], @"attributesOfItemAtPath:userData:error should return no attribute entries");
    STAssertNil(error, @"attributesOfItemAtPath:userData:error should return no error");
    STAssertTrue([target openFileAtPath:@"/foo/bar" mode:O_RDONLY userData:&userData error:&error], @"openFileAtPath:mode:userData:error should return true");
    STAssertNil(error, @"openFileAtPath:mode:userData:error should return no error");
    STAssertEqualObjects([NSNumber numberWithLong:0], userData, @"openFileAtPath:mode:userData:error should return no userData");
    char buffer[1024];
    STAssertEquals(0, [target readFileAtPath:@"/foo/bar" userData:userData buffer:buffer size:sizeof(buffer) offset:100 error:&error], @"readFileAtPath:userData:buffer:offset:error should return 0");
    STAssertNil(error, @"readFileAtPath:userData:buffer:offset:error should return no error");
    [target releaseFileAtPath:@"/foo/bar" userData:userData];
    STAssertEquals(0uL, [[target extendedAttributesOfItemAtPath:@"/foo/bar" error:&error] count], @"extendedAttributesOfItemAtPath:error should return no attributes");
    STAssertNil(error, @"extendedAttributesOfItemAtPath:error should return no error");
}

@end
