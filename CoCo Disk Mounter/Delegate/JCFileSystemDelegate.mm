//
//  JCRsDosFileSystemDelegate.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-28.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#include <string>
#include <map>

#include "../Model/NilFileSystem.h"
#import "../Delegate/JCError.h"
#import "JCFileSystemDelegate.h"

#include "JCConversionUtils.h"


@implementation JCFileSystemDelegate

+ (NSDictionary *)attributeDictionaryFromMap:(const std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> &)map {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long>::const_iterator iter(map.begin());
        iter != map.end();
        iter++) {
        
        // Get and convert the pair
        const CoCoDiskMounter::IFileSystem::Attribute_t attribute = (*iter).first;
        NSString *dictionaryAttribute = [JCFileSystemDelegate dictionaryAttributeFromMapAttribute:attribute];
        long value = (*iter).second;
        NSString *dictValue = [JCFileSystemDelegate dictionaryAttributeValueFromMapAttribute:attribute mapValue:value];
        
        // Put new pair into dictionary
        if (dictionaryAttribute != nil)
            dictionary[dictionaryAttribute] = dictValue;
    }
    
    return dictionary;
}

+ (NSString *)dictionaryAttributeFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)attribute {
    switch(attribute) {
        case CoCoDiskMounter::IFileSystem::AttributeFileType:
            return NSFileType;
        case CoCoDiskMounter::IFileSystem::AttributeFileSize:
            return NSFileSize;
        case CoCoDiskMounter::IFileSystem::AtributeFileModificationDate:
            return NSFileModificationDate;
        case CoCoDiskMounter::IFileSystem::AttributeReferenceCount:
            return NSFileReferenceCount;
        case CoCoDiskMounter::IFileSystem::AttributePosixPermissions:
            return NSFilePosixPermissions;
        case CoCoDiskMounter::IFileSystem::AttributeOwnerAccountID:
            return NSFileOwnerAccountID;
        case CoCoDiskMounter::IFileSystem::AttributeGroupOwnerAccountID:
            return NSFileGroupOwnerAccountID;
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileNumber:
            return NSFileSystemFileNumber;
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey:
            return kGMUserFileSystemFileBackupDateKey;
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey:
            return kGMUserFileSystemFileChangeDateKey;
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey:
            return kGMUserFileSystemFileAccessDateKey;
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileFlagsKey:
            return kGMUserFileSystemFileFlagsKey;
        default:
            return nil;
    }
}

+ (id)dictionaryAttributeValueFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)attribute mapValue:(long)value {
    switch(attribute) {
        case CoCoDiskMounter::IFileSystem::AttributeFileType:
            return [JCFileSystemDelegate dictionaryFileTypeFromMapFileType:static_cast<CoCoDiskMounter::IFileSystem::FileType_t>(value)];
        
        case CoCoDiskMounter::IFileSystem::AtributeFileModificationDate:
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileBackupDateKey:
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileChangeDateKey:
        case CoCoDiskMounter::IFileSystem::AttributeSystemFileAccessDateKey:
            return [NSDate dateWithTimeIntervalSince1970:value/1000.0];
            
        default:
            return [NSNumber numberWithLong:value];
    }
}

+ (NSString *)dictionaryFileTypeFromMapFileType:(CoCoDiskMounter::IFileSystem::FileType_t)fileType {
    switch(fileType) {
        case CoCoDiskMounter::IFileSystem::FileTypeRegular:
            return NSFileTypeRegular;
        
        case CoCoDiskMounter::IFileSystem::FileTypeDirectory:
            return NSFileTypeDirectory;
        
        case CoCoDiskMounter::IFileSystem::FileTypeSymbolicLink:
            return NSFileTypeSymbolicLink;

        default:
            return NSFileTypeUnknown;
    }
}

+ (CoCoDiskMounter::IFileSystem::FileOpenMode_t) fileOpenModeFromOpenMode:(int)openMode {
    if (openMode == O_RDONLY) return CoCoDiskMounter::IFileSystem::FileOpenModeReadOnly;
    throw CoCoDiskMounter::IOException();
}

- (id)init {
    std::shared_ptr<CoCoDiskMounter::IFileSystem> fileSystem(new CoCoDiskMounter::NilFileSystem());
    return [self initWithFileSystem:fileSystem];
}


- (id)initWithFileSystem:(std::shared_ptr<CoCoDiskMounter::IFileSystem>)fileSystem {
    if ((self = [super init])) {
        _fileSystem = fileSystem;
    }
    return self;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)dir error:(NSError **)error {
    // Place directory contents into contents
    std::vector<std::string> contents;
    try {
        _fileSystem->contentsOfDirectoryAtPath(contents, std::string([dir UTF8String]));
        *error = nil;
    } catch(CoCoDiskMounter::Exception &e) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainGeneric userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:e.getReason().c_str()] forKey:NSLocalizedDescriptionKey]];
        return nil;
    }

    // Transfer contents to array
    NSMutableArray *contentArray = [NSMutableArray array];
    for(std::vector<std::string>::iterator iter = contents.begin();
        iter != contents.end();
        iter++) {
        [contentArray addObject:[NSString stringWithUTF8String:(*iter).c_str()]];
    }
    
    return contentArray;
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path
                  userData:(id)userData
                  error:(NSError **)error {
    try {
        std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> mapAttributes;
        _fileSystem->getPropertiesOfFile(mapAttributes, JCConvertNSStringToString(path));
        *error = nil;
        return [JCFileSystemDelegate attributeDictionaryFromMap:mapAttributes];
    } catch(const CoCoDiskMounter::FileNotFoundException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainNotAFile userInfo:nil];
        return nil;
    } catch(const CoCoDiskMounter::IOException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainIO userInfo:nil];
        return nil;
    } catch(const CoCoDiskMounter::Exception &exception) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainGeneric userInfo:nil];
        return nil;
    }
}

- (BOOL)openFileAtPath:(NSString *)path
                  mode:(int)mode
              userData:(id *)userData
                 error:(NSError **)error {
    try {
        CoCoDiskMounter::IFileSystem::FileOpenMode_t openMode = [JCFileSystemDelegate fileOpenModeFromOpenMode:mode];
        *userData = [NSNumber numberWithLong:(long)_fileSystem->openFileAtPath(JCConvertNSStringToString(path), openMode)];
        *error = nil;
        return YES;
    } catch(const CoCoDiskMounter::FileNotFoundException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainNotAFile userInfo:nil];
        return NO;
    } catch(const CoCoDiskMounter::IOException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainIO userInfo:nil];
        return NO;
    } catch(const CoCoDiskMounter::Exception &e) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainGeneric userInfo:nil];
        return NO;
    }
}

- (void)releaseFileAtPath:(NSString *)path userData:(id)userData {
    _fileSystem->closeFile((void *)[userData longValue]);
}

- (int)readFileAtPath:(NSString *)path
             userData:(id)userData
               buffer:(char *)buffer
                 size:(size_t)size
               offset:(off_t)offset
               error:(NSError **)error {
    try {
        return (int)_fileSystem->readFile((void *)[userData longValue], buffer, size, offset);
    } catch(const CoCoDiskMounter::FileNotFoundException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainNotAFile userInfo:nil];
        return -1;
    } catch(const CoCoDiskMounter::IOException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainIO userInfo:nil];
        return -1;
    }
}

- (NSArray *)extendedAttributesOfItemAtPath:path
                                     error:(NSError **)error {
    *error = nil;
    return [NSArray array];
}

@end
