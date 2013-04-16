//
//  MockDiskImage.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#pragma once

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "../../CoCo Disk Mounter/Model/DiskImage.h"

namespace CoCoDiskMounterTest {
    class MockDiskImage : public CoCoDiskMounter::DiskImage {
    public:
        MOCK_METHOD6(read, int(unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset));
        
        MOCK_METHOD6(write, int(const unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset));
    };
}
