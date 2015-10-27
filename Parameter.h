//
//  Parameter.h
//  Python
//
//  Created by Stephan Witoszynskyj on 11.01.12.
//  Copyright 2012 Stephan Witoszynskyj. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Parameter : NSObject <NSCoding> {
	NSString *name;
	NSString *value;
}

@property (retain) NSString *name;
@property (retain) NSString *value;

- (id)init;
- (id)initWithParameter:(Parameter*)parameter;
- (void)dealloc;

@end
