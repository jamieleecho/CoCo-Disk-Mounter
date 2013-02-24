//
//  JVCDiskImage.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#ifndef __CoCo_Disk_Mounter__JVCDiskImage__
#define __CoCo_Disk_Mounter__JVCDiskImage__

#include <fstream>

#include "DiskImage.h"
#include "Exception.h"

namespace CoCoDiskMounter {
    /** low-level class for reading JVC disk images */
    class JVCDiskImage : public DiskImage {
    public:
        /** number of sectors per track */
        static const int NUM_SECTORS_PER_TRACK = 18;
        
        /** number of bytes per sector */
        static const int NUM_BYTES_PER_SECTOR = 256;
        
        /** number of bytes per track */
        static const int NUM_BYTES_PER_TRACK = NUM_SECTORS_PER_TRACK * NUM_BYTES_PER_SECTOR;
        
        /**
         * Creates a JVCDiskImage from the given file.
         * Throws if the image does not look quite right.
         */
        JVCDiskImage(const char *filename);
        
        int read(unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset = 0);
        
        int write(const unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset = 0);
        
    private:
        /**
         * Gets the given offset location.
         * @param track track to move to
         * @param sector in track to move to
         * @param sectorOffset offset in sector to move to
         * @return the location offset in bytes
         */
        int getPosition(int track, int sector, int sectorOffset = 0);
        
        /**
         * Positions get _file to the given location.
         * @param track track to move to
         * @param sector in track to move to
         * @param sectorOffset offset in sector to move to
         * @return the location offset in bytes
         */
        int setPositionG(int track, int sector, int sectorOffset = 0);
        
        /**
         * Positions put _file to the given location.
         * @param track track to move to
         * @param sector in track to move to
         * @param sectorOffset offset in sector to move to
         * @return the location offset in bytes
         */
        int setPositionP(int track, int sector, int sectorOffset = 0);
        
        /** provides file access */
        std::fstream _file;
        
        /** size of the file in bytes */
        int _fileSize;
        
    };
}

#endif /* defined(__CoCo_Disk_Mounter__JVCDiskImage__) */
