//
//  MacHammer_RuntimeAppDelegate.h
//  MacHammer Runtime
//
//  Created by Filipp Lepalaan on 13.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MacHammer_RuntimeAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
