//
//  Exception.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-29.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#pragma once

#include <string>

namespace CoCoDiskMounter {
    /** Thrown when an unexpected error occurs */
    class Exception {
    public:
        /**
         * Creates an Exception.
         *
         * @param[input] reason that caused the exception
         */
        Exception(const std::string &reason = "") : _reason(reason) {}

        /** @return cause of the exception */
        const std::string &getReason() const { return _reason; }

    private:
        std::string _reason;
    };

    /** Thrown when an IO error occurs */
    class IOException : public Exception {
    public:
        /**
         * Creates an Exception.
         *
         * @param[input] reason that caused the exception
         */
        IOException(const std::string &reason = "") : Exception(reason) {}
    };

    /** Thrown when a file does not exist */
    class FileNotFoundException : public IOException {
    public:
        /**
         * Creates a FileNotFoundException Exception.
         * @param[input] filename  what caused the exception
         */
        FileNotFoundException(const std::string &filename = "") : IOException(filename + " could not be found"), _filename(filename) {}

        /** @return filename that could not be found */
        const std::string &getFilename() const { return _filename; }
        
    private:
        std::string _filename;
    };

    /**
     * Thrown when the user does not have permission to a file
     */
    class FilePermissionException : public IOException {
    public:
        /**
         * Creates a FilePermissionException Exception.
         * @param[input] filename what caused the exception
         */
        FilePermissionException(const std::string &filename = "") : IOException(filename + " could not be accessed"), _filename(filename) {}
        
        /** @return filename that could not be found */
        const std::string &getFilename() const { return _filename; }
        
    private:
        /** filename that could not be found */
        std::string _filename;
    };
    
    /**
     * Thrown when the file has a bad file format
     */
    class BadFileFormatException : public IOException {
    public:
        /**
         * Creates a BadFileFormat Exception.
         * @param[input] filename what caused the exception
         */
        BadFileFormatException(const std::string &filename = "") : IOException(filename + " has an unknown file type"), _filename(filename) {}
        
        /** @return filename that had the bad format */
        const std::string &getFilename() const { return _filename; }
        
    private:
        /** filename of file with bad format */
        std::string _filename;
    };

    /**
     * Thrown when the file is not a directory
     */
    class NotADirectoryException : public IOException {
    public:
        /**
         * Creates a NotADirectoryException Exception.
         * @param[input] filename what caused the exception
         */
        NotADirectoryException(const std::string &filename = "") : IOException(filename + " is not a directory"), _filename(filename) {}
        
        /** @return filename that did not refer to a directory */
        const std::string &getFilename() const { return _filename; }
        
    private:
        
        /** filename that did not refer to a directory */
        std::string _filename;
    };

    
    /**
     * Thrown when the filename does not refer to a file
     */
    class NotAFileException : public IOException {
    public:
        /**
         * Creates a NotAFileException Exception.
         * @param[input] filename what caused the exception
         */
        NotAFileException(const std::string &filename = "") : IOException(filename + " is not a file"), _filename(filename) {}
        
        /** @return filename that was not a file */
        const std::string &getFilename() const { return _filename; }
        
    private:
        
        /** filename that did not refer to a file */
        std::string _filename;
    };
}

