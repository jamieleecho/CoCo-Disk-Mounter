//
//  RSDosFileSystemTest.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-06-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "RSDosFileSystemTest.h"
#include "../../CoCo Disk Mounter/Model/JVCDiskImage.h"
#include "../../CoCo Disk Mounter/Model/RsDosFileSystem.h"
#include "../../CoCo Disk Mounter/Delegate/JCConversionUtils.h"

#include "RsDosFileSystemTest.h"

using namespace CoCoDiskMounter;
using namespace std;


static std::string getPathForDiskFileResource(NSString *str) {
    NSBundle *bundle = [NSBundle bundleForClass:[RSDosFileSystemTest class]];
    NSString *path = [bundle pathForResource:str ofType:@"dsk"];
    return JCConvertNSStringToString(path);
}


@implementation RSDosFileSystemTest

- (void)testBasicConstants {
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::DIRECTORY_TRACK, 17, @"Wrong directory track");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::GRANULE_MAP_SECTOR, 1, @"Wrong granule map sector");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::DIRECTORY_LIST_SECTOR, 2, @"Wrong directory list location");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::NUM_GRANULES, 68, @"Wrong number of granules");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::DIRECTORY_LIST_NUM_SECTORS, 12, @"Number of sectors in directory list is wrong");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES, 2304, @"Granule should have 2304 bytes");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_SECTORS, 9, @"Granules are 9 sectors long");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::TRACK_SIZE_GRANULES, 2, @"Each track has 2 granules");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::SECTOR_SIZE_BYTES, 256, @"Each sector has 256 bytes");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::FILENAME_MAX_LENGTH, 8, @"Each filename has at most 8 characters (bytes)");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::EXTENSION_MAX_LENGTH, 3, @"Each extension has at most 3 characters (bytes)");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::FILE_ENTRY_TYPE_OFFSET, 11, @"File entry type must be located directly after the filename");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::FILE_ENTRY_IS_ASCII_OFFSET, 12, @"The mark noting that the file is entry is immediately after the file entry type");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::FILE_ENTRY_FIRST_GRANULE_OFFSET, 13, @"The first granule of the file is located immediately after the ascii mark");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::FILE_ENTRY_NUM_BYTES_USED_IN_LAST_SECTOR_OFFSET, 14, @"The number of bytes used in the last sector of the file is located immediately after the first granule");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::DIRECTORY_ENTRY_LENGTH, 32, @"Each directory entry takes 32 bytes");
    STAssertEquals(CoCoDiskMounter::RsDosFileSystem::NUM_DIRECTORY_ENTRIES, 72, @"There are 72 directory entries");
}

- (void)testGetTerminatedString {
    STAssertTrue(CoCoDiskMounter::RsDosFileSystem::getSpaceTerminatedString((unsigned const char *)"The Quick Brown Fox", 8) == "The Quic", @"getSpaceTerminatedString() not returning expected result");
    STAssertTrue(CoCoDiskMounter::RsDosFileSystem::getSpaceTerminatedString((unsigned const char *)"The Quick Brown Fox", 11) == "The Quick B", @"getSpaceTerminatedString() not returning expected result");
    STAssertTrue(CoCoDiskMounter::RsDosFileSystem::getSpaceTerminatedString((unsigned const char *)"The Quick Brown Fox", 10) == "The Quick", @"getSpaceTerminatedString() not returning expected result");
    STAssertTrue(CoCoDiskMounter::RsDosFileSystem::getSpaceTerminatedString((unsigned const char *)"The     ", 8) == "The", @"getSpaceTerminatedString() not returning expected result");
    STAssertTrue(CoCoDiskMounter::RsDosFileSystem::getSpaceTerminatedString((unsigned const char *)" Th ", 3) == " Th", @"getSpaceTerminatedString() not returning expected result");
}

- (void)testGranuleMapGetFreeSpace {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertEquals(target.getNumFreeGranules(), 25, @"Number of free granules should be 25");
    STAssertEquals(target.getNumFreeBytes(), 25 * RsDosFileSystem::GRANULE_SIZE_BYTES, @"Number of free granules should be 25 * RsDosFileSystem::GRANULE_SIZE_BYTES");
}

- (void)testGranuleMapGetNumSectors {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertEquals(target.getNumSectors(0), 0, @"File at granule 0 should have 0 sectors");
    STAssertEquals(target.getNumSectors(1), 0, @"File at granule 1 should have 0 sectors");
    STAssertEquals(target.getNumSectors(9), 0, @"File at granule 9 should have 0 sectors");
    STAssertEquals(target.getNumSectors(10), 0, @"File at granule 10 should have 0 sectors - the map says one but it is partially filled so is NOT counted here");
    STAssertEquals(target.getNumSectors(12), 6, @"File at granule 12 should have 6 sectors - the map says 7 but last is partially filled so is NOT counted here");
    STAssertEquals(target.getNumSectors(14), 24, @"File at granule 14 should have 24 sectors - two full granules (14 and 15) and granule 12 with 6 full sectors");
    STAssertEquals(target.getNumSectors(66), 0, @"File at granule 66 should have 0 sectors");
    STAssertEquals(target.getNumSectors(67), 0, @"File at granule 67 should have 0 sectors");
}

- (void)testGranuleMapIsValid {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    for(int ii=0; ii<=0x43; ii++)
        STAssertTrue(target.isValid(ii), @"granules 0x00 to 0x43 should be valid");
    for(int ii=0xc0; ii<=0xc9; ii++)
        STAssertTrue(target.isValid(ii), @"granules 0x00 to 0xc9 should be valid");
    for(int ii=0x44; ii<=0xbf; ii++)
        STAssertFalse(target.isValid(ii), @"granules 0x44 to 0xbf should be invalid");
    for(int ii=0xca; ii<0xff; ii++)
        STAssertFalse(target.isValid(ii), @"granules 0xca to 0xfe should be invalid");
    STAssertTrue(target.isValid(0xff), @"granules 0xff should be valid");
}

- (void)testGranuleMapGetGranuleValue {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertEquals(target.getGranuleValue(0), 0xff, @"granule 0 should be 0xff");
    STAssertEquals(target.getGranuleValue(0xa), 0xc1, @"granule 0x0a should be 0xc1");
    STAssertEquals(target.getGranuleValue(0x20), 0x21, @"granule 0x20 should be 0x21");
    STAssertEquals(target.getGranuleValue(0x30), 0x31, @"granule 0x30 should be 0x31");
    STAssertEquals(target.getGranuleValue(0x40), 0xff, @"granule 0x40 should be 0xff");
    STAssertEquals(target.getGranuleValue(0x43), 0xff, @"granule 0x43 should be 0xff");
}

- (void)testGranuleMapIsFree {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertTrue(target.isFree(0xff), @"granule value 0xff should indicate it is free");
    STAssertFalse(target.isFree(0xc1), @"granule value 0xc1 should indicate it is not free");
    STAssertFalse(target.isFree(0x20), @"granule value 0x20 should indicate it is not free");
    STAssertFalse(target.isFree(0x0), @"granule value 0x0 should indicate it is not free");
}

- (void)testGranuleMapIsLastGranule {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertTrue(target.isLastGranule(0xff), @"granule value 0xff should indicate it is a last granule (not really, should not matter)");
    STAssertTrue(target.isLastGranule(0xc1), @"granule value 0xc1 should indicate it is a last granule");
    STAssertTrue(target.isLastGranule(0xc9), @"granule value 0xc9 should indicate it is a last granule");
    STAssertTrue(target.isLastGranule(0x80), @"granule value 0x80 should indicate it is a last granule (not really, should not matter)");
    STAssertFalse(target.isLastGranule(0x79), @"granule value 0x79 should indicate it is not a last granule");
    STAssertFalse(target.isLastGranule(0x39), @"granule value 0x39 should indicate it is not a last granule");
    STAssertFalse(target.isLastGranule(0x29), @"granule value 0x29 should indicate it is not a last granule");
    STAssertFalse(target.isLastGranule(0x9), @"granule value 0x19 should indicate it is not a last granule");
    STAssertFalse(target.isLastGranule(0x9), @"granule value 0x9 should indicate it is not a last granule");
    STAssertFalse(target.isLastGranule(0x0), @"granule value 0x0 should indicate it is not a last granule");
}

- (void)testGranuleMapNumSectorsInGranule {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    STAssertEquals(target.numSectorsInGranule(0xff), 0, @"granule value 0xff should indicate no used sectors");
    STAssertEquals(target.numSectorsInGranule(0x0), 9, @"granule value 0x0 should indicate nine used sectors");
    STAssertEquals(target.numSectorsInGranule(0x11), 9, @"granule value 0x11 should indicate nine used sectors");
    STAssertEquals(target.numSectorsInGranule(0x31), 9, @"granule value 0x31 should indicate nine used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc0), 0, @"granule value 0xc0 should indicate 0 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc1), 1, @"granule value 0xc1 should indicate 1 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc2), 2, @"granule value 0xc2 should indicate 2 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc3), 3, @"granule value 0xc3 should indicate 3 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc4), 4, @"granule value 0xc4 should indicate 4 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc5), 5, @"granule value 0xc5 should indicate 5 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc6), 6, @"granule value 0xc6 should indicate 6 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc7), 7, @"granule value 0xc7 should indicate 7 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc8), 8, @"granule value 0xc8 should indicate 8 used sectors");
    STAssertEquals(target.numSectorsInGranule(0xc9), 9, @"granule value 0xc9 should indicate 9 used sectors");
}

- (void)testGranuleMapGetOffsetGranule {
    const string sgu5DiskPath = getPathForDiskFileResource(@"SGU5");
    shared_ptr<DiskImage> sgu5Disk(new JVCDiskImage(sgu5DiskPath.c_str()));
    CoCoDiskMounter::RsDosFileSystem::GranuleMap target(sgu5Disk);
    try {
        target.getOffsetGranule(0x0, CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES);
        STFail(@"Should throw IOException because granule 0 is free");
    } catch(IOException &) {
    }
    
    STAssertEquals(target.getOffsetGranule(0x0c, (7 * CoCoDiskMounter::RsDosFileSystem::SECTOR_SIZE_BYTES) - 1), 0x0c, @"Should be 0x0c because we have not gone past this granule");
    
    try {
        target.getOffsetGranule(0x0c, (7 * CoCoDiskMounter::RsDosFileSystem::SECTOR_SIZE_BYTES));
        STFail(@"Should throw IOException because granule we have gone past the last free sector");
    } catch(IOException &) {
    }

    STAssertEquals(0xe, target.getOffsetGranule(0x0e, CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES - 1), @"Should be 0xe because we have not gone past this granule");
    STAssertEquals(0xf, target.getOffsetGranule(0x0e, CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES), @"Should be 0xf because we have gone past this granule");
    STAssertEquals(0xf, target.getOffsetGranule(0x0e, (2 * CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES) - 1), @"Should be 0xf because we have gone past this granule");
    STAssertEquals(0xc, target.getOffsetGranule(0x0e,  2 * CoCoDiskMounter::RsDosFileSystem::GRANULE_SIZE_BYTES), @"Should be 0xf because we have gone through two granules");

}

@end
