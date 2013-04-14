//
//  GmockInitializer.cpp
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-14.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#include "GmockInitializer.h"
#include "gmock/gmock.h"

bool GmockInitializer::_initialized = false;

void GmockInitializer::initialize() {
    if (!_initialized) {
        _initialized = true;
        ::testing::GTEST_FLAG(throw_on_failure) = true;
        int argc = 0;
        char **argv = (char **)NULL;
        
        ::testing::InitGoogleMock(&argc, argv);
    }
}
