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

bool JCFileSystemDelegateRunFunctionAndHandleExceptions(const std::function<void()>& func, NSError **error) {
    try {
        func();
        *error = nil;
        return true;
    } catch(const CoCoDiskMounter::FileNotFoundException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainFileNotFound userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:notFoundException.getReason().c_str()] forKey:NSLocalizedDescriptionKey]];
        return false;
    } catch(const CoCoDiskMounter::IOException &notFoundException) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainIO userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:notFoundException.getReason().c_str()] forKey:NSLocalizedDescriptionKey]];
        return false;
    } catch(const CoCoDiskMounter::Exception &exception) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainGeneric userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:exception.getReason().c_str()] forKey:NSLocalizedDescriptionKey]];
        return false;
    } catch(...) {
        *error = [NSError errorWithDomain:JCErrorDomain code:JCErrorDomainGeneric userInfo:[NSDictionary dictionaryWithObject:@"Unknown Exception" forKey:NSLocalizedDescriptionKey]];
        return false;
    }
}

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
    std::vector<std::string> contents;
    auto func = [self, dir, &contents] () mutable {
        _fileSystem->contentsOfDirectoryAtPath(contents, std::string([dir UTF8String]));
    };
    if (JCFileSystemDelegateRunFunctionAndHandleExceptions(func, error)) {
        // Transfer contents to array
        NSMutableArray *contentArray = [NSMutableArray array];
        for(std::vector<std::string>::iterator iter = contents.begin();
            iter != contents.end();
            iter++) {
            [contentArray addObject:[NSString stringWithUTF8String:(*iter).c_str()]];
        }
        return contentArray;
    }
    
    return nil;
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path
                  userData:(id)userData
                  error:(NSError **)error {
    std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> mapAttributes;
    auto func = [self, path, &mapAttributes] () mutable {
        _fileSystem->getPropertiesOfFile(mapAttributes, JCConvertNSStringToString(path));
    };
    if (JCFileSystemDelegateRunFunctionAndHandleExceptions(func, error))
        return [JCFileSystemDelegate attributeDictionaryFromMap:mapAttributes];
    
    return nil;
}

- (BOOL)openFileAtPath:(NSString *)path
                  mode:(int)mode
              userData:(id *)userData
                 error:(NSError **)error {
    auto func = [self, path, userData, mode] () mutable {
        CoCoDiskMounter::IFileSystem::FileOpenMode_t openMode = [JCFileSystemDelegate fileOpenModeFromOpenMode:mode];
        *userData = [NSNumber numberWithLong:(long)_fileSystem->openFileAtPath(JCConvertNSStringToString(path), openMode)];
    };
    return JCFileSystemDelegateRunFunctionAndHandleExceptions(func, error);
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
    int retval;
    auto func = [self, path, buffer, size, offset, &retval, userData] () mutable {
        retval = (int)_fileSystem->readFile((void *)[userData longValue], buffer, size, offset);
    };
    return JCFileSystemDelegateRunFunctionAndHandleExceptions(func, error) ? retval : -1;
}

- (NSArray *)extendedAttributesOfItemAtPath:path
                                     error:(NSError **)error {
    *error = nil;
    return [NSArray array];
}

@end
