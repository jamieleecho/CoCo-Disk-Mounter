//
//  GmockInitializer.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2013-04-14.
//  Copyright (c) 2013 Jamie Cho. All rights reserved.
//

#ifndef __CoCo_Disk_Mounter__GmockInitializer__
#define __CoCo_Disk_Mounter__GmockInitializer__

class GmockInitializer {
public:
    static void initialize();
    
private:
    static bool _initialized;
};

#endif /* defined(__CoCo_Disk_Mounter__GmockInitializer__) */
