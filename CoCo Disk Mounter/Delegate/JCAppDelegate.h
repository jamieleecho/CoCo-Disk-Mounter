//
//  JCAppDelegate.h
//  CoCo Disk Mounter
//
//  Created by Jamie Cho on 2012-12-28.
//  Copyright (c) 2012 Jamie Cho. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OSXFUSE/OSXFUSE.h>

@interface JCAppDelegate : NSObject <NSApplicationDelegate> {
    GMUserFileSystem *filesystem;
}

@property (assign) IBOutlet NSWindow *window;

@end
