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
const NSInteger JCErrorDomainGeneric = 1;
const NSInteger JCErrorDomainIO = 2;
const NSInteger JCErrorDomainFileNotFound = 3;
const NSInteger JCErrorDomainFilePermission = 4;
const NSInteger JCErrorDomainBadFileFormat = 5;
const NSInteger JCErrorDomainNotADirectory = 6;
const NSInteger JCErrorDomainNotAFile = 7;

#endif
