//
//  PythonFilter.m
//  Python
//
//  Copyright (c) 2011 Stephan. All rights reserved.
//

#import "PythonFilter.h"
#import "ExecController.h"

@implementation PythonFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
	
	ExecController *window = [[ExecController alloc] initWithWindowNibName:@"ExecController"];
	[window showWindow:nil];
	
	return 0;
}

@end
