//
//  NilFileSystem.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-01-13.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#pragma once

#include "IFileSystem.h"

namespace CoCoDiskMounter {
    class NilFileSystem : public IFileSystem {
    public:
        NilFileSystem() { }
        void contentsOfDirectoryAtPath(std::vector<std::string> &contents, const std::string &path);
        long getSize() { return 0; }
        long getFreeSpace() { return 0; }
        long getNodes() {return 0; }
        long getFreeNodes() {return 0; }
        void getPropertiesOfFile(std::map<Attribute_t, long> &attributes, const std::string &path) { }
        virtual void *openFileAtPath(const std::string &path, FileOpenMode_t mode) { return NULL; }
        virtual void closeFile(void *descriptor) { }
        virtual size_t readFile(void *descriptor, char *buffer, size_t size, size_t offset) { return 0; }
   };
}
