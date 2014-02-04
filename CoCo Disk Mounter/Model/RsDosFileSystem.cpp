//
//  RsDosFileSystem.cpp
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#include "RsDosFileSystem.h"


namespace CoCoDiskMounter {
    int RsDosFileSystem::GranuleMap::getNumSectors(int granule) {
        clearGranuleVisitedMap();
        int granuleCount = 0;
        int numLastSectors = 0;
        bool moreGranules = false;
        do {
            // Validate the granule
            if ((granule < 0) || (granule > NUM_GRANULES))
                return 0;
            
            // Make sure we are not in a circular chain
            if (_granuleVisitedMap[granule])
                return 0;
            
            // Make sure that the granuleEntry is valid
            int granuleEntry = _granuleMap[granule];
            if (!isValid(granuleEntry) || isFree(granuleEntry))
                return 0;
            
            // Last granule entry?
            moreGranules = !isLastGranule(granuleEntry) && !isFree(granuleEntry);
            if (moreGranules) {
                _granuleVisitedMap[granule] = true;
                granule = granuleEntry;
                granuleCount++;
            } else {
                numLastSectors = numSectorsInGranule(granuleEntry);
                numLastSectors = (numLastSectors <= 0) ? 0 : numLastSectors - 1;
            }
        } while(moreGranules);
        
        return granuleCount * GRANULE_SIZE_SECTORS + numLastSectors;
    }
    
    int RsDosFileSystem::GranuleMap::getNumFreeGranules() const {
        int count = 0;
        for(int ii=0; ii<sizeof(_granuleMap)/sizeof(_granuleMap[0]); ii++)
            if (isFree(_granuleMap[ii]))
                count++;
        return count;
    }
    
    int RsDosFileSystem::GranuleMap::getOffsetGranule(int granule, size_t offset) {
        clearGranuleVisitedMap();
        while(true) {
            // Validate the granule
            if ((granule < 0) || (granule >= NUM_GRANULES))
                throw IOException();
            
            // Make sure we are not in a circular chain
            if (_granuleVisitedMap[granule])
                throw IOException();
            
            // Make sure that the granuleEntry is valid
            int granuleEntry = _granuleMap[granule];
            if (!isValid(granuleEntry))
                throw IOException();
            
            if (isLastGranule(granuleEntry)) {
                // This is the last granule in the file. See if offset comes before
                // the last sector.
                const int numSectors = numSectorsInGranule(granuleEntry);
                if (offset >= (numSectors * SECTOR_SIZE_BYTES))
                    throw IOException();
                return granule;
            }

            // Mark that we have visited this granule
            _granuleVisitedMap[granule] = true;
            
            // Determine whether or not we must iterate to the next granule
            if (offset < GRANULE_SIZE_BYTES)
                break;
            
            // Move on to the next iteration
            granule = granuleEntry;
            offset -= GRANULE_SIZE_BYTES;
        }
        
        return granule;
    }
    
    RsDosFileSystem::DirectoryEntry::DirectoryEntry(std::shared_ptr<CoCoDiskMounter::DiskImage> diskImage, int entryNumber) : _entryNumber(entryNumber) {
        unsigned char buffer[DIRECTORY_ENTRY_LENGTH];
        int bytesRead = diskImage->read(buffer, 0, DIRECTORY_ENTRY_LENGTH, DIRECTORY_TRACK, DIRECTORY_LIST_SECTOR, entryNumber * DIRECTORY_ENTRY_LENGTH);
        if ((bytesRead == false) || ((buffer[0] & 0x80) != 0) || (buffer[0] == 0)) {
            _free = true;
            _type = FileTypeBasic;
            _isASCII = false;
            _firstGranule = 0;
            _numBytesUsedInLastSector = 0;
            return;
        }
        
        // Construct the filename
        _filename.append(getSpaceTerminatedString(buffer, FILENAME_MAX_LENGTH));
        _extension.append(getSpaceTerminatedString(buffer + FILENAME_MAX_LENGTH, EXTENSION_MAX_LENGTH));
        if ((_filename.size() == 0) && (_extension.size() == 0)) {
            _free = true;
            _type = FileTypeBasic;
            _isASCII = false;
            _firstGranule = 0;
            _numBytesUsedInLastSector = 0;
            return;
        }

        // Get the kind of file
        _free = false;
        _type = FileTypeBasic;
        _isASCII = buffer[FILE_ENTRY_IS_ASCII_OFFSET] != 0;
        _type = (FileType)(FILE_ENTRY_TYPE_MASK & buffer[FILE_ENTRY_TYPE_OFFSET]);
        _firstGranule = buffer[FILE_ENTRY_FIRST_GRANULE_OFFSET];
        _numBytesUsedInLastSector = (((int)buffer[FILE_ENTRY_NUM_BYTES_USED_IN_LAST_SECTOR_OFFSET]) << 8) | buffer[FILE_ENTRY_NUM_BYTES_USED_IN_LAST_SECTOR_OFFSET + 1];
    }
    
    void RsDosFileSystem::contentsOfDirectoryAtPath(std::vector<std::string> &contents, const std::string &path) {
        if (path != "/") return;
        for(int ii=0; ii<NUM_DIRECTORY_ENTRIES; ii++) {
            DirectoryEntry directoryEntry(_diskImage, ii);
            if (directoryEntry.isFree())
                continue;
            contents.push_back(directoryEntry.getFilenameAndExtension());
        }
    }
    
    void RsDosFileSystem::getPropertiesOfFile(std::map<Attribute_t, long> &attributes, const std::string &path) {
        // Root directory
        if (path == "/") {
            attributes[AttributeFileType] = FileTypeDirectory;
            attributes[AttributeFileSize] = 0;
            attributes[AttributeReferenceCount] = 1;
            return;
        }

        // Find and populate the directory entry
        DirectoryEntry directoryEntry(directoryEntryForFile(path));
        attributes[AttributeFileType] = FileTypeRegular;
        int numSectorsForFile = _granuleMap.getNumSectors(directoryEntry.getFirstGranule());
        int fileSizeBytes = (numSectorsForFile * SECTOR_SIZE_BYTES) + directoryEntry.getNumBytesUsedInLastSector();
        attributes[AttributeFileSize] = fileSizeBytes;
        attributes[AttributeReferenceCount] = 1;
    }
    
    void *RsDosFileSystem::openFileAtPath(const std::string &path, FileOpenMode_t mode) {
        // We only support read only right now
        if (mode != FileOpenModeReadOnly)
            throw CoCoDiskMounter::FilePermissionException();

        // Get the directory entry and make sure that it is not free
        DirectoryEntry directoryEntry(directoryEntryForFile(path));
        if (directoryEntry.isFree())
            throw FileNotFoundException();
        
        // Put the entry number into the open file list
        std::shared_ptr<OpenFileDescriptor> openFile(new OpenFileDescriptor(directoryEntry.getEntryNumber(), mode));
        _openFileList.push_front(openFile);
        
        // Return the descriptor
        return openFile.get();
    }
    
    void RsDosFileSystem::closeFile(void *descriptor) {
        // Make sure the descriptor exists and remove from the list
        std::shared_ptr<RsDosFileSystem::OpenFileDescriptor> file = RsDosFileSystem::getOpenFile(descriptor, FileOpenModeNone);
        SharedPointerPredicate<RsDosFileSystem::OpenFileDescriptor> filePredicate(file.get());
        size_t sz = _openFileList.size();
        _openFileList.remove_if(filePredicate);
        
        // Really should never happen
        if (_openFileList.size() == sz)
            throw IOException();
    }
    
    size_t RsDosFileSystem::readFile(void *descriptor, char *buffer, size_t size, size_t offset) {
        // Get the directory entry
        std::shared_ptr<RsDosFileSystem::OpenFileDescriptor> file = RsDosFileSystem::getOpenFile(descriptor, FileOpenModeReadOnly);
        DirectoryEntry entry(_diskImage, file->getDirectoryEntryNumber());

        // In this loop we try to read granule by granule. There are a couple cases and combinations
        // we must consider:
        // 1. When we start exactly on a granule
        // 2. When we start in the middle of a granule
        // 3. When the granule is not complete
        // 4. When we have more buffer space or run out of buffer space
        int totalBytesRead = 0;
        for (int firstGranule = entry.getFirstGranule();
             size > 0;) {
            // Get the granule and the offset into granule that we need
            int granuleByteOffset = offset % GRANULE_SIZE_BYTES;
            
            // Figure out where we start and end in the granule, how much data to read
            int granuleValue = _granuleMap.getGranuleValue(firstGranule);
            int sectorsInGranule = _granuleMap.numSectorsInGranule(granuleValue);
            int bytesInGranule = _granuleMap.isLastGranule(granuleValue) ? (((sectorsInGranule > 0) ? ((sectorsInGranule - 1) * SECTOR_SIZE_BYTES) + entry.getNumBytesUsedInLastSector() : 0)) : (sectorsInGranule * SECTOR_SIZE_BYTES);
            int maxBytesToReadInGranule = bytesInGranule - granuleByteOffset;
            int bytesToReadInGranule = (maxBytesToReadInGranule < size) ? maxBytesToReadInGranule : (int)size;
            if (bytesToReadInGranule < 0)
                throw Exception("Error: skipped beyond the length of the file!");
            if (bytesToReadInGranule == 0)
                break;
            int startTrack = (firstGranule / TRACK_SIZE_GRANULES);
            int startSector = (firstGranule % TRACK_SIZE_GRANULES) * GRANULE_SIZE_SECTORS;
            if (startTrack >= DIRECTORY_TRACK) startTrack++;

            // Read the data. We take advantage that read allows sector offsets greater than the sector size.            
            int bytesRead = _diskImage->read((unsigned char *)buffer, totalBytesRead, bytesToReadInGranule, startTrack, startSector, granuleByteOffset);
            if (bytesRead <= 0)
                throw Exception("Error: Unable to read data from disk!");
            size = size - bytesRead;
            totalBytesRead += bytesRead;
            
            // Iterate to the next granule
            if (_granuleMap.isLastGranule(granuleValue)) break;
            firstGranule = granuleValue;
            offset = 0;
        }
        
        return (totalBytesRead == 0) ? -1 : totalBytesRead;
    }
    
    RsDosFileSystem::DirectoryEntry RsDosFileSystem::directoryEntryForFile(const std::string &path) {
        // Get the filename part of the path
        if ((path.size() <= 1) || (path[0] != '/'))
            throw FileNotFoundException(path);
        const std::string filename(path.substr(1));

        // Iterate through the directories until we find the entry
        for(int ii=0; ii<NUM_DIRECTORY_ENTRIES; ii++) {
            // Did we find the entry?
            DirectoryEntry directoryEntry(_diskImage, ii);
            if (directoryEntry.isFree())
                continue;
            if (directoryEntry.getFilenameAndExtension() != filename)
                continue;
            
            return directoryEntry;
        }
        
        throw FileNotFoundException(path);        
    }
    
    std::shared_ptr<RsDosFileSystem::OpenFileDescriptor> RsDosFileSystem::getOpenFile(void *descriptor, FileOpenMode_t mode) {
        // Find the opened file
        SharedPointerPredicate<RsDosFileSystem::OpenFileDescriptor> filePredicate(descriptor);
        for(std::list<std::shared_ptr<RsDosFileSystem::OpenFileDescriptor> >::iterator iter = _openFileList.begin();
            iter != _openFileList.end();
            iter++) {
            if (filePredicate(*iter)) {
                if (((*iter)->getFileOpenMode() & mode) != mode)
                    throw FilePermissionException();
                return *iter;
            }
        }
        
        throw IOException();
    }
}

