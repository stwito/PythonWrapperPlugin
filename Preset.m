//
//  Preset.m
//  Python
//
//  Created by Stephan Witoszynskyj on 11.01.12.
//  Copyright 2012 Stephan Witoszynskyj. All rights reserved.
//

#import "Preset.h"
#import "Parameter.h"


@implementation Preset

@synthesize name;
@synthesize pyFile;
@synthesize function;
@synthesize parameters;
@synthesize savedValues;
@synthesize runInTerminal;


- (id)init {
	if (self = [super init]) {
		self.name          = nil;
		self.pyFile        = @"";
		self.function      = @"";
		self.parameters    = [[[NSMutableArray alloc] init] autorelease];
		self.runInTerminal = YES;
		self.savedValues   = [Preset alloc];
		[self setSaved];
	}
	
	return self;
}

- (id)initWithPreset:(Preset*)preset {
	if (self = [super init]) {
		self.name          = preset.name;
		self.pyFile        = preset.pyFile;
		self.function      = preset.function;
		self.parameters    = [[[NSMutableArray alloc] init] autorelease];
		for (id parameter in preset.parameters) {
			[parameters addObject:[[[Parameter alloc] initWithParameter:parameter] autorelease]];
		}
		self.runInTerminal = preset.runInTerminal;
		self.savedValues   = [Preset alloc];
		[self setSaved];
	}
	
	return self;
}

- (void)dealloc {
	self.name        = nil;
	self.pyFile      = nil;
	self.function    = nil;
	self.parameters  = nil;
	self.savedValues = nil;
	
	[super dealloc];
}

- (void)revertToSaved {
	self.name          = self.savedValues.name;
	self.pyFile        = self.savedValues.pyFile;
	self.function      = self.savedValues.function;
	self.runInTerminal = self.savedValues.runInTerminal;
	[parameters removeAllObjects];
	for (id parameter in savedValues.parameters) {
		[parameters addObject:[[[Parameter alloc] initWithParameter:parameter] autorelease]];
	}
}

- (void)setSaved {
	savedValues.name          = self.name;
	savedValues.pyFile        = self.pyFile;
	savedValues.function      = self.function;
	savedValues.parameters    = [[[NSMutableArray alloc] init] autorelease];
	for (id parameter in parameters) {
		[savedValues.parameters addObject:[[[Parameter alloc] initWithParameter:parameter] autorelease]];
	}
	savedValues.runInTerminal = self.runInTerminal;
}

#pragma mark -
#pragma mark support for saving/loading

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name          forKey:@"name"];
	[coder encodeObject:pyFile        forKey:@"pyFile"];
	[coder encodeObject:function      forKey:@"function"];
	[coder encodeObject:parameters    forKey:@"parameters"];
	[coder encodeObject:[NSNumber numberWithBool:runInTerminal] forKey:@"runInTerminal"];
	
	[self setSaved];
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		self.name          = [coder decodeObjectForKey:@"name"];
		self.pyFile        = [coder decodeObjectForKey:@"pyFile"];
		self.function      = [coder decodeObjectForKey:@"function"];
		self.parameters    = [coder decodeObjectForKey:@"parameters"];
		self.runInTerminal = [[coder decodeObjectForKey:@"runInTerminal"] boolValue];
		
		self.savedValues = [Preset alloc];
		[self setSaved];
	}
	
	return self;
}

@end
