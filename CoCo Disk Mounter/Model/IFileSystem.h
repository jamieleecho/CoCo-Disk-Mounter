//
//  IFileSystem.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-01-27.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#pragma once

#include <map>
#include <string>
#include <vector>
#include <iostream>

namespace CoCoDiskMounter {
    class IFileSystem {
    public:
        /** attribute keys for file information */
        enum Attribute_t {
            AttributeFileType = 0,
            AttributeFileSize,
            AtributeFileModificationDate,
            AttributeReferenceCount,
            AttributePosixPermissions,
            AttributeOwnerAccountID,
            AttributeGroupOwnerAccountID,
            AttributeSystemFileNumber,
            AttributeSystemFileBackupDateKey,
            AttributeSystemFileChangeDateKey,
            AttributeSystemFileAccessDateKey,
            AttributeSystemFileFlagsKey
        };
        
        /** different possible types for AttributeFileType */
        enum FileType_t {
            FileTypeRegular = 0,
            FileTypeDirectory = 1,
            FileTypeSymbolicLink = 2
        };
        
        /** how a file can be opened */
        enum FileOpenMode_t {
            FileOpenModeNone = 0,
            FileOpenModeReadOnly = 1,
            FileOpenModeWriteOnly = 2,
            FileOpenModeReadWrite = 3
        };
        
        /**
         * Appends the contents of the directory at path to path. Should throw on any error.
         
         * @param contents to be filled with filenames of directory at path
         * @param path path to directory
         */
        virtual void contentsOfDirectoryAtPath(std::vector<std::string> &contents, const std::string &path) = 0;
        
        /** @return the size of the filesystem in bytes */
        virtual long getSize() = 0;
        
        /** @return the number of free bytes in the filesystem */
        virtual long getFreeSpace() = 0;
        
        /** @return the maximum number of nodes of the filesystem */
        virtual long getNodes() = 0;
        
        /** @return the maximum number of free nodes on the filesystem */
        virtual long getFreeNodes() = 0;
        
        /**
         * Puts the attributes of the file located at path into attributes. Should throw on any error.
         
         * @param[output] attributes appends filesystem attribute information into attributes
         * @param[input] path path of file to query
         */
        virtual void getPropertiesOfFile(std::map<Attribute_t, long> &attributes, const std::string &path) = 0;
        
        /**
         * Opens a file at path for the given read/write mode. Throws if the file could not be opened for the given access mode.
         * @param[input] path file to open. If mode is FileOpenModeWriteOnly or FileOpenModeReadWrite, create the file if needed.
         * @param[input] mode mode to use when opening file
         * @return descriptor that uniquely specifies operations on the file
         */
        virtual void *openFileAtPath(const std::string &path, FileOpenMode_t mode) = 0;
        
        /**
         * Closes the open file with the given descriptor. If the file is opened, the file must be closed after this operation.
         * However, failures may still occur if not all data had previously been written and the function may then throw.
         * @param[input] descriptor file to close
         */
        virtual void closeFile(void *descriptor) = 0;
        
        /**
         * Reads upto size bytes from the file.
         * @param[input] descriptor descriptor returned by openFileAtPath or createFileAtPath.
         * @param[input] buffer buffer to store data
         * @param[input] size size of buffer in bytes
         * @param[input] offset offset into file
         */
        virtual size_t readFile(void *descriptor, char *buffer, size_t size, size_t offset) = 0;
    };
}
