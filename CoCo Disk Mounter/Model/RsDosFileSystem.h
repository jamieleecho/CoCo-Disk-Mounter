//
//  RsDosFileSystem.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#pragma once

#include <list>
#include <memory>

#include "FileSystem.h"

namespace CoCoDiskMounter {
    class RsDosFileSystem : public FileSystem {
    public:
        /** directory on which track information is stored */
        static const int DIRECTORY_TRACK = 17;
        
        /** sector on DIRECTORY_TRACK on which the granule map is located */
        static const int GRANULE_MAP_SECTOR = 1;
        
        /** sector on DIRECTORY_TRACK on which directory list begins */
        static const int DIRECTORY_LIST_SECTOR = 2;
        
        /** number of granules on a disk */
        static const int NUM_GRANULES = 68;
        
        /** num of sectors used by the directory list */
        static const int DIRECTORY_LIST_NUM_SECTORS = 12;

        /** number of bytes in each granule */
        static const int GRANULE_SIZE_BYTES = 2304;
        
        /** number of sectors in each granule */
        static const int GRANULE_SIZE_SECTORS = 9;
        
        /** size of each track in granules */
        static const int TRACK_SIZE_GRANULES = 2;
        
        /** number of bytes in each sector */
        static const int SECTOR_SIZE_BYTES = 256;
        
        /** maximum length of each filename (excluding extension) */
        static const int FILENAME_MAX_LENGTH = 8;
        
        /** maximum length of each extension (excluding the dot) */
        static const int EXTENSION_MAX_LENGTH = 3;
        
        /** offset to the file entry type */
        static const int FILE_ENTRY_TYPE_OFFSET = (FILENAME_MAX_LENGTH + EXTENSION_MAX_LENGTH);
        
        /** offset to whether or not the file is ascii */
        static const int FILE_ENTRY_IS_ASCII_OFFSET = (FILE_ENTRY_TYPE_OFFSET + 1);
        
        /** offset to the file's first granule */
        static const int FILE_ENTRY_FIRST_GRANULE_OFFSET = (FILE_ENTRY_IS_ASCII_OFFSET + 1);
        
        /** offset to the file's first granule */
        static const int FILE_ENTRY_NUM_BYTES_USED_IN_LAST_SECTOR_OFFSET = (FILE_ENTRY_FIRST_GRANULE_OFFSET + 1);
        
        /** number of bytes per directory entry */
        static const int DIRECTORY_ENTRY_LENGTH = 32;
        
        /** number of directory entries */
        static const int NUM_DIRECTORY_ENTRIES = 72;
        
        /** @returns the word that is space terminated */
        static const std::string getSpaceTerminatedString(unsigned const char *buffer, int maxNumChars) {
            int count = maxNumChars;
            while(--count >= 0) {
                if (buffer[count] != ' ')
                    break;
            }
            
            return std::string((const char *)buffer, (count >= 0) ? count+1 : maxNumChars);
        }
        
        /** represents the granule map */
        class GranuleMap {
        public:
            /**
             * Creates a GranuleMap from diskImage.
             */
            GranuleMap(std::shared_ptr<DiskImage> diskImage) : _diskImage(diskImage) {
                loadGranules();
            }
            
            /**
             * @param[input] granule starting granule of file
             * @return the number of sectors used by file starting at granule
             */
            int getNumSectors(int granule);
            
            /** 
             * @return the number of free granules
             */
            int getNumFreeGranules() const;
            
            /** 
             * @return the number of free bytes
             */
            int getNumFreeBytes() const { return getNumFreeGranules() * GRANULE_SIZE_BYTES; }
            
            /**
             * @param[input] granuleValue value of a granuleValue for which isLastGranule(granuleValue) is true
             * @return whether or not granuleValue is valid
             */
            bool isValid(int granuleValue) const {
                return ((granuleValue >= 0) && (granuleValue <= 0x43)) ||
                       ((granuleValue >= 0xc0) && (granuleValue <= 0xc9)) ||
                       (granuleValue >= 0xff);
            }
            
            /** 
             * @param[input] granule granule index
             * @return value for given granule index.
             */
            int getGranuleValue(int granule) const {
                return _granuleMap[granule];
            }
            
            /**
             * @param[input] granuleValue value of a granuleValue for which isLastGranule(granuleValue) is true
             * @return whether or not corresponding granule is free
             */
            bool isFree(int granuleValue) const {
                return (granuleValue == 0xff);
            }
            
            /**
             * @param[input] granuleValue value of a granule entry
             * @return whether or not this is the last granule in the chain
             */
            bool isLastGranule(int granuleValue) const {
                return (granuleValue & 0x80) == 0x80;
            }
            
            /**
             * @param[input] granuleValue value of a granuleValue for which isLastGranule(granuleValue) is true
             * @return the number of sectors in the last granule
             */
            int numSectorsInGranule(int granuleValue) const {
                if (!isLastGranule(granuleValue)) return GRANULE_SIZE_SECTORS;
                int numSectors = granuleValue & 0xf;
                return ((numSectors >= 0) && (numSectors < 9)) ? numSectors : 9;
            }
            
            /**
             * @param granule starting granule
             * @param size_t offset in bytes
             * @return granule with the given byte offset from startGranule
             */
            int getOffsetGranule(int granule, size_t offset);
            
        private:
            /**
             * Loads the granule entries. Should be invoked before other operations are performed.
             */
            void loadGranules() {
                _diskImage->read(_granuleMap, 0, NUM_GRANULES, DIRECTORY_TRACK, GRANULE_MAP_SECTOR);
            }
            
            /** clears _granuleVisitedMap to false. */
            void clearGranuleVisitedMap() {
                memset(_granuleVisitedMap, 0, sizeof(_granuleVisitedMap));
            }
            
            /** The disk image that contains the granule map */
            std::shared_ptr<DiskImage> _diskImage;
            
            /** holds the granules */
            unsigned char _granuleMap[NUM_GRANULES];

            /** maps that holds whether or not a granule has been visited */
            bool _granuleVisitedMap[NUM_GRANULES];
        };

        /** different types of files */
        enum FileType {
            FileTypeBasic = 0x0,
            FileTypeBasicData = 0x1,
            FileTypeMachineCodeProgram = 0x2,
            FileTypeTextEditor = 0x3,
            FILE_ENTRY_TYPE_MASK = 0x3
        };
        
        /** represents a directory list entry */
        class DirectoryEntry {
        public:
            /** 
             * Creates a DirectoryEntry for the given entry number.
             */
            DirectoryEntry(std::shared_ptr<DiskImage> diskImage, int entryNumber);
            
            /** @return the filename e.g. foo */
            std::string getFilename() const { return _filename; }

            /** @return the filename e.g. txt */
            std::string getExtension() const { return _extension; }
            
            /** @return the filename and extension. e.g. foo.txt */
            std::string getFilenameAndExtension() const { return _filename + "." + _extension; }
            
            /** @return whether or not the entry is free */
            bool isFree() const { return _free; }
            
            /** @return Whether or not a file is ASCII  */
            bool isASCII() const { return _isASCII; }
            
            /** @return kind of file */
            FileType getType() const { return _type; }
            
            /** @return first granule used by the file */
            int getFirstGranule() const { return _firstGranule; }
            
            /** @return number of bytes used by the last granule */
            int getNumBytesUsedInLastSector() const { return _numBytesUsedInLastSector; }
            
            /** @return the entryNumber for this DirectoryEntry. */
            int getEntryNumber() const { return _entryNumber; }
            
        private:
            /** main name of the file */
            std::string _filename;
            
            /** extension part of the filename */
            std::string _extension;
            
            /** whether or not this spot is free*/
            bool _free;
            
            /** whether or not this file is ASCII */
            bool _isASCII;
            
            /** type of saved file */
            FileType _type;
            
            /** first granule used */
            int _firstGranule;
            
            /** number of bytes used in file's last sector */
            int _numBytesUsedInLastSector;
            
            /** entry number for thi s entry */
            const int _entryNumber;
        };
        
        /**
         * Represents an open file.
         */
        class OpenFileDescriptor {
        public:
            /**
             * @param directoryEntryNumber DirectoryEntry entry number
             * @param fileOpenMode file mode in which file was opened
             */
            OpenFileDescriptor(int directoryEntryNumber, FileOpenMode_t fileOpenMode) :
            _directoryEntryNumber(directoryEntryNumber), _fileOpenMode(fileOpenMode) { }
            
            /** @return DirectoryEntry entry number of open file */
            int getDirectoryEntryNumber() const { return _directoryEntryNumber; };

            /** @return file mode in which file was opened */
            int getFileOpenMode() const { return _fileOpenMode; };

            /** @return whether or not the file can be read */
            bool canRead() const { return (_fileOpenMode & FileOpenModeReadOnly) != 0; }

            /** @return whether or not the file can be written */
            bool canWrite() const { return (_fileOpenMode & FileOpenModeWriteOnly) != 0; }
            
        private:
            /** entry number of open file */
            const int _directoryEntryNumber;

            /** file mode in which file was opened */
            const FileOpenMode_t _fileOpenMode;
        };
        
        /** Predicate for determining whether or not std::shared_ptr<T> 
         *  has a given pointer. */
        template <class T>
        class SharedPointerPredicate {
        public:
            SharedPointerPredicate(void *ptr) : _ptr(ptr) { }
            
            /** 
             * @param[input] ptr item to compare
             * @return whether or not ptr has the pointer for we are searching.
             */
            bool operator() (const std::shared_ptr<T> &ptr) {
                if (_ptr == ptr.get()) {
                    return true;
                }
                return false;
            }
            
        private:
            /** pointer to find */
            const void *_ptr;
        };
        
        /**
         * Creates an RsDosFileSystem from the given DiskImage.
         * @param diskImage disk containing an RS-DOS filesystem.
         */
        RsDosFileSystem(std::shared_ptr<DiskImage> diskImage) : FileSystem(diskImage), _granuleMap(diskImage) { }
        
        void contentsOfDirectoryAtPath(std::vector<std::string> &contents, const std::string &path);
        
        long getSize() { return NUM_GRANULES * GRANULE_SIZE_BYTES; }
        
        long getFreeSpace() { return _granuleMap.getNumFreeBytes(); }

        long getNodes() { return NUM_GRANULES; }
        
        long getFreeNodes() { return _granuleMap.getNumFreeGranules(); }
        
        void getPropertiesOfFile(std::map<Attribute_t, long> &attributes, const std::string &path);
        
        void *openFileAtPath(const std::string &path, FileOpenMode_t mode);
        
        void closeFile(void *descriptor);
        
        size_t readFile(void *descriptor, char *buffer, size_t size, size_t offset);

    private:
        /**
         * @param[input] path path of file to find
         * @return DirectoryEntry for the given path.
         */
        DirectoryEntry directoryEntryForFile(const std::string &path);
        
        /**
         * @param[input] descriptor returned by openFileAtPath.
         * @param[input] mode how the file will be accessed (FileOpenModeReadOnly, FileOpenModeWriteOnly or FileOpenModeNone)
         * @return shared pointer to OpenFileDescriptor
         */
        std::shared_ptr<OpenFileDescriptor> getOpenFile(void *descriptor, FileOpenMode_t mode);
        
        /** represents the granule map of this filesystem */
        GranuleMap _granuleMap;
        
        /** list of open files */
        std::list<std::shared_ptr<OpenFileDescriptor> > _openFileList;
    };
}
