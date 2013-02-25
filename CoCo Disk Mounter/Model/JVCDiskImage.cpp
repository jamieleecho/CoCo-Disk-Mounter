//
//  JVCDiskImage.cpp
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#include "JVCDiskImage.h"
#include "Exception.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

using namespace std;

namespace CoCoDiskMounter {
    JVCDiskImage::JVCDiskImage(const char *filename) : _file(filename, ios::in | ios::out | ios::binary) {
        // If we failed to open the file, try to figure out why
        if (!_file) {
            struct stat sb;
            if (::stat(filename, &sb) == -1)
                if (errno == EACCES) throw FilePermissionException(filename);
            throw FileNotFoundException(filename);
        }

        // Get the size of the file
        struct stat sb;
        if (::stat(filename, &sb) == -1)
            throw FilePermissionException(filename);
        _fileSize = (int)sb.st_size;
        if ((sb.st_size % NUM_BYTES_PER_TRACK) != 0)
            throw BadFileFormatException(filename);
    }
    
    int JVCDiskImage::read(unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset) {
        // Compute the area of the file to read
        int fullOffset = setPositionG(track, sector, sectorOffset);
        if (fullOffset > _fileSize) return 0;
        int finalOffset = fullOffset + nchars;
        if (finalOffset > _fileSize) fullOffset = finalOffset;
        
        // Seek to the correct position and perform the read
        int bytesToRead = finalOffset - fullOffset;
        _file.read((char *)buffer + offset, bytesToRead);
        if (_file.fail())
            throw IOException("Read failed for some reason");
        
        return (int)_file.tellg() - fullOffset;
    }
    
    int JVCDiskImage::write(const unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset) {
        // Compute the area of the file to read
        int fullOffset = setPositionP(track, sector, sectorOffset);
        if (fullOffset > _fileSize) return 0;
        int finalOffset = fullOffset + nchars;
        if (finalOffset > _fileSize) fullOffset = finalOffset;
        
        // Seek to the correct position and perform the read
        _file.write((const char *)buffer, finalOffset - fullOffset);
        if (_file.fail())
            throw IOException("Write failed for some reason");
        
        return (int)_file.tellp() - fullOffset;
    }
    
    int JVCDiskImage::getPosition(int track, int sector, int sectorOffset) {
        // Compute the area of the file to read
        int fullOffset = (track * NUM_BYTES_PER_TRACK) + (sector * NUM_BYTES_PER_SECTOR) + sectorOffset;
        if (fullOffset > _fileSize) return fullOffset;
        _file.seekp(fullOffset, ios_base::beg);
        
        return fullOffset;
    }

    int JVCDiskImage::setPositionG(int track, int sector, int sectorOffset) {
        int fullOffset = getPosition(track, sector, sectorOffset);
        _file.seekg(fullOffset, ios_base::beg);
        return fullOffset;
    }

    int JVCDiskImage::setPositionP(int track, int sector, int sectorOffset) {
        int fullOffset = getPosition(track, sector, sectorOffset);
        _file.seekp(fullOffset, ios_base::beg);
        return fullOffset;
    }
}