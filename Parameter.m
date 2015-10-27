//
//  Parameter.m
//  Python
//
//  Created by Stephan Witoszynskyj on 11.01.12.
//  Copyright 2012 Stephan Witoszynskyj. All rights reserved.
//

#import "Parameter.h"


@implementation Parameter

@synthesize name;
@synthesize value;

- (id)init {
	if (self = [super init]) {
		self.name  = @"";
		self.value = @"";
	}
	
	return self;
}

- (id)initWithParameter:(Parameter*)parameter {
	if (self = [super init]) {
		self.name  = parameter.name;
		self.value = parameter.value;
	}
	
	return self;
}

- (void)dealloc {
	self.name  = nil;
	self.value = nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark support for saving/loading

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name  forKey:@"name"];
	[coder encodeObject:value forKey:@"value"];
	
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		self.name  = [coder decodeObjectForKey:@"name"];
		self.value = [coder decodeObjectForKey:@"value"];
	}
	
	return self;
}

@end
