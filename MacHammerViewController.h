//
//  MacHammerViewController.h
//
//  Created by Filipp Lepalaan on 13.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBJson.h"

@interface MacHammerViewController : NSObject {
    IBOutlet id runButton;
    IBOutlet NSTableView *workflowTable;
	IBOutlet NSWindow *mainWindow;
	
	SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;
	
	NSArray *workflows;
	
}
- (IBAction)runWorkflow:(id)sender;
- workflows;
- (void) setWorkflows: (NSArray*)input;
@end
