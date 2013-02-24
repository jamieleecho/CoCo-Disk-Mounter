//
//  JCError.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-16.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#ifndef CoCo_Disk_Mounter_JCError_h
#define CoCo_Disk_Mounter_JCError_h

/** Domain to use for the following errors */
extern NSString *JCErrorDomain;

/** Errors to use with the JCErrorDomain */
const int JCErrorDomainIO = 1;
const int JCErrorDomainFileNotFound = 2;
const int JCErrorDomainFilePermission = 3;
const int JCErrorDomainBadFileFormat = 4;
const int JCErrorDomainNotADirectory = 5;
const int JCErrorDomainNotAFile = 6;

#endif
