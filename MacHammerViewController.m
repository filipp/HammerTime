//
//  MacHammerViewController.m
//
//  Created by Filipp Lepalaan on 13.7.2011.
//  Copyright 2011 Filipp Lepalaan. All rights reserved.
//

#import "MacHammerViewController.h"

@interface MacHammerViewController () <SBJsonStreamParserAdapterDelegate>
@end

@implementation MacHammerViewController

-(void)awakeFromNib
{
	[mainWindow center];
	
	// let's start by identifying this machine
	NSTask *t = [[[NSTask alloc] init] autorelease];
	NSPipe *p = [[[NSPipe alloc] init] autorelease];
	
	[t setStandardOutput:p];
	[t setLaunchPath:@"/usr/sbin/sysctl"];
	[t setArguments:[NSArray arrayWithObjects:@"-n", @"hw.model", nil]];
	
	[t launch];
	
	NSFileHandle *fh = [p fileHandleForReading];
	NSData *inData = [fh readDataToEndOfFile];
	[t waitUntilExit];
	
	NSString *modelId = [[NSString stringWithUTF8String:[inData bytes]] 
						 stringByTrimmingCharactersInSet:
						 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSLog(@"Running on: %@", modelId);
	
	NSString *url = @"http://0.0.0.0:3000/home/ping";
	url = [url stringByAppendingFormat:@"/%@.json", modelId];
	
	NSLog(@"Checking: %@", url);
	
	adapter = [[SBJsonStreamParserAdapter alloc] init];
	adapter.delegate = self;
	parser = [[SBJsonStreamParser alloc] init];
	parser.delegate = adapter;
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest 
									 requestWithURL:[NSURL URLWithString:url]
									 cachePolicy:NSURLRequestUseProtocolCachePolicy
									 timeoutInterval:60.0];
	
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
	
}

- (IBAction)runWorkflow:(id)sender {
    
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [workflows count];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   row:(int)rowIndex
{
	//	NSDictionary *dataRecord = [[self comparisonData] objectAtIndex:rowIndex];
	//	return [dataRecord objectForKey:[tableColumn identifier]];
	NSLog(@"Fetching row index: %u", rowIndex);
//	NSLog(@"BLABLAA: %@", [workflows description]);
//	return @"Blaaa";
	NSDictionary *dict = [workflows objectAtIndex:rowIndex];
	return [[dict objectForKey:@"workflow"] valueForKey:@"title"];
	
}

#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
	//    [NSException raise:@"unexpected" format:@"Should not get here"];
}

-(void)setWorkflows:(NSArray *)input
{
    [workflows autorelease];
    workflows = [input retain];
}

-(NSArray*)workflows
{
    return workflows;
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	
	NSLog(@"Found this: %@", [dict description]);
	
	if ([dict objectForKey:@"pong"] != nil)
	{
		NSDictionary *response = [dict objectForKey:@"pong"];
		NSString *title = [[response objectForKey:@"productDescription"] objectAtIndex:0];
		[mainWindow setTitle:title];
		
		[self setWorkflows:[response objectForKey:@"workflows"]];
		
		NSLog(@"Downloaded %lu workflows", [workflows count]);
		[workflowTable reloadData];
        [runButton setEnabled:YES];
	}
		
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (void)connection:(NSURLConnection *)connection 
	didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
	
	/*
	 NSURLCredential *credential = [NSURLCredential credentialWithUser:username.text
	 password:password.text
	 persistence:NSURLCredentialPersistenceForSession];
	 
	 [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	 */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %lu", data.length);
	
	// Parse the new chunk of data. The parser will append it to
	// its internal buffer, then parse from where it left off in
	// the last chunk.
	
	SBJsonStreamParserStatus status = [parser parse:data];
	
	if (status == SBJsonStreamParserError) {
		// tweet.text = [NSString stringWithFormat: @"The parser encountered an error: %@", parser.error];
		NSLog(@"Parser error: %@", parser.error);
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		NSLog(@"Parser waiting for more data");
	}

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [connection release];
//    [adapter release];
//    [parser release];
}

@end
