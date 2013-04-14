//
//  MockFileSystem.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-14.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#ifndef CoCo_Disk_Mounter_MockFileSystem_h
#define CoCo_Disk_Mounter_MockFileSystem_h

#include "gmock/gmock.h"
#import "../../CoCo Disk Mounter/Model/IFileSystem.h"

namespace CoCoDiskMounterTest {
    class MockFileSystem : public CoCoDiskMounter::IFileSystem {
    public:
        MOCK_METHOD2(contentsOfDirectoryAtPath, void (std::vector<std::string> &contents, const std::string &path));
        
        MOCK_METHOD0(getSize, long ());
        
        MOCK_METHOD0(getFreeSpace, long ());
        
        MOCK_METHOD0(getNodes, long ());
        
        MOCK_METHOD0(getFreeNodes, long ());
        
        MOCK_METHOD2(getPropertiesOfFile, void (std::map<Attribute_t, long> &attributes, const std::string &path));
        
        MOCK_METHOD2(openFileAtPath, void *(const std::string &path, FileOpenMode_t mode));
        
        MOCK_METHOD1(closeFile, void(void *descriptor));
        
        MOCK_METHOD4(readFile, size_t(void *descriptor, char *buffer, size_t size, size_t offset));
    };    
}

#endif
