//
//  RSDosFileSystemTest.m
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-06-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "RSDosFileSystemTest.h"
#include "../../CoCo Disk Mounter/Model/RsDosFileSystem.h"
#include "RsDosFileSystemTest.h"

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

@end
