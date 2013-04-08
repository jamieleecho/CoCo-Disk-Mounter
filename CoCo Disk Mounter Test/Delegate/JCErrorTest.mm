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
    STAssertEquals(1l, JCErrorDomainGeneric, @"");
    STAssertEquals(2l, JCErrorDomainIO, @"");
    STAssertEquals(3l, JCErrorDomainFileNotFound, @"");
    STAssertEquals(4l, JCErrorDomainFilePermission, @"");
    STAssertEquals(5l, JCErrorDomainBadFileFormat, @"");
    STAssertEquals(6l, JCErrorDomainNotADirectory, @"");
    STAssertEquals(7l, JCErrorDomainNotAFile, @"");
}

@end
