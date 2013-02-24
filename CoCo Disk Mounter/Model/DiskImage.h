//
//  DiskImage.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#pragma once

namespace CoCoDiskMounter {
    class DiskImage {
    public:
        /**
         * Reads nchar bytes of data starting at track and sector at sectorOffset and writes the result
         * into buffer + offset. If the data goes over sector, goes to the next sector. If the data
         * goes over to the next track, starts at the next track at sector 0. If more data is requested
         * than is on the disk image, returns as much data as possible.
         *
         * @param[output] buffer destination of read data
         * @param[input] offset offset to start writing into buffer
         * @param[input] nchars number of characters to read
         * @param[input] track track from which to start reading
         * @param[input] sector in track from which to start reading
         * @param[input] sectorOffset offset in sector from which to start reading.
         * @return number of bytes read
         */
        virtual int read(unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset = 0) = 0;

        /**
         * Writes nchar bytes of data starting at track and sector at sectorOffset and writes the result
         * into buffer + offset. If the data goes over sector, goes to the next sector. If the data
         * goes over to the next track, starts at the next track at sector 0. If more data must be written
         * than is on the disk image, writes as much data as possible.
         *
         * @param[input] buffer source data to write
         * @param[input] offset offset to start reading from buffer
         * @param[input] nchars number of characters to read
         * @param[input] track track from which to start reading
         * @param[input] sector in track from which to start reading
         * @param[input] sectorOffset offset in sector from which to start reading.
         * @return number of bytes written
         */
        virtual int write(const unsigned char *buffer, int offset, int nchars, int track, int sector, int sectorOffset = 0) = 0;
    };
}
