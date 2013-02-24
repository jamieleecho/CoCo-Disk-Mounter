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
    STAssertEquals(@"CoCoDiskMounterErrorDomain", JCErrorDomain, @"");
    STAssertEquals(1, JCErrorDomainIO, @"");
    STAssertEquals(2, JCErrorDomainFileNotFound, @"");
    STAssertEquals(3, JCErrorDomainFilePermission, @"");
    STAssertEquals(4, JCErrorDomainBadFileFormat, @"");
    STAssertEquals(5, JCErrorDomainNotADirectory, @"");
    STAssertEquals(6, JCErrorDomainNotAFile, @"");
}

@end
