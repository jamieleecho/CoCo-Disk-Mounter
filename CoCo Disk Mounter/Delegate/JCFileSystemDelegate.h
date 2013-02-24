//
//  JCRsDosFileSystemDelegate.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-28.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <memory>
#include "IFileSystem.h"

@interface JCFileSystemDelegate : NSObject {
    /** Represents the file system for this delegate */
    std::shared_ptr<CoCoDiskMounter::IFileSystem> _fileSystem;
}

/**
 * @return attribute NSDictionary from attribute map.
 */
+ (NSDictionary *)attributeDictionaryFromMap:(const std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> &)map;

/**
 * @return attribute map from attribute NSDictionary.
 */
+ (void)attributeMap:(const std::map<CoCoDiskMounter::IFileSystem::Attribute_t, long> &)map fromDictionary:(NSDictionary *)dict;

/**
 * @return a dictionary attribute from a map attribute.
 */
+ (NSString *)dictionaryAttributeFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)attribute;

/**
 * @return a dictionary attribute value from a map attribute and its value
 */
+ (id)dictionaryAttributeValueFromMapAttribute:(CoCoDiskMounter::IFileSystem::Attribute_t)attribute mapValue:(long)value;

/**
 * @return a dictionary file type from a map file type.
 */
+ (NSString *)dictionaryFileTypeFromMapFileType:(CoCoDiskMounter::IFileSystem::FileType_t)fileType;

/**
 * @param[input] openMode standard UNIX open mode
 * @return equivalent FileOpenMode_t.
 */
+ (CoCoDiskMounter::IFileSystem::FileOpenMode_t)fileOpenModeFromOpenMode:(int)openMode;

- (id)initWithFileSystem:(std::shared_ptr<CoCoDiskMounter::IFileSystem>)fileSystem;

@end
