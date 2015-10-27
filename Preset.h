//
//  Preset.h
//  Python
//
//  Created by Stephan Witoszynskyj on 11.01.12.
//  Copyright 2012 Stephan Witoszynskyj. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Preset : NSObject <NSCoding> {
	NSString       *name;
	NSString       *pyFile;
	NSString       *function;
	NSMutableArray *parameters;
	BOOL           runInTerminal;
	
	Preset   *savedValues;
}

@property (retain) NSString       *name;
@property (retain) NSString       *pyFile;
@property (retain) NSString       *function;
@property (retain) NSMutableArray *parameters;
@property (retain) Preset         *savedValues;
@property (assign) BOOL            runInTerminal;


- (id)init;
- (id)initWithPreset:(Preset*)preset;
- (void)dealloc;
- (void)revertToSaved;

- (void)setSaved;

@end
