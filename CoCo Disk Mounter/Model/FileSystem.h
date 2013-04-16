//
//  FileSystem.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#pragma once

#include <map>
#include <memory>
#include <vector>
#include <iostream>

#include "DiskImage.h"
#include "IFileSystem.h"
#include "Exception.h"

namespace CoCoDiskMounter {
    class FileSystem : public IFileSystem {
    public:
        /**
         * Creates a FileSystem object that uses diskImage for IO.
         * @param diskImage disk image to use for IO operations.
         */
        FileSystem(std::shared_ptr<DiskImage> &diskImage) : _diskImage(diskImage) { }
    
    protected:
        /** disk image to use for IO operations */
        std::shared_ptr<DiskImage> _diskImage;
    };
}
