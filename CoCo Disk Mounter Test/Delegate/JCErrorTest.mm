//
//  JCErrorTest.mm
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-02-24.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#import "JCErrorTest.h"
#import "../../CoCo Disk Mounter/Delegate/JCError.h"

@implementation JCErrorTest

- (void)testErrorConstants {
    STAssertEquals(JCErrorDomain, @"CoCoDiskMounterErrorDomain", @"");
    STAssertEquals(JCErrorDomainGeneric, 1L, @"");
    STAssertEquals(JCErrorDomainIO, 2L, @"");
    STAssertEquals(JCErrorDomainFileNotFound, 3L, @"");
    STAssertEquals(JCErrorDomainFilePermission, 4L, @"");
    STAssertEquals(JCErrorDomainBadFileFormat, 5L, @"");
    STAssertEquals(JCErrorDomainNotADirectory, 6L, @"");
    STAssertEquals(JCErrorDomainNotAFile, 7L, @"");
}

@end
