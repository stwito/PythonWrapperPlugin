//
//  ExecController.h
//  Python
//
//  Created by Stephan Witoszynskyj on 19.12.11.
//  Copyright 2011 Stephan Witoszynskyj. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OsiriXAPI/BrowserController.h>

#import "Preset.h"

@interface ExecController : NSWindowController {
	IBOutlet NSPopUpButton *presetsPopUp;
	IBOutlet NSTextField   *fileField;
	IBOutlet NSTextField   *functionField;
	IBOutlet NSTableView   *parameterTable;
	IBOutlet NSPanel       *saveAsDialog;
	IBOutlet NSTextField   *saveAsField;
	IBOutlet NSButton      *runInTerminalField;
	
	NSMutableArray         *presets;
	Preset                 *currentPreset;
}

@property (retain) IBOutlet NSPopUpButton *presetsPopUp;
@property (retain) IBOutlet NSTextField   *fileField;
@property (retain) IBOutlet NSTextField   *functionField;
@property (retain) IBOutlet NSTableView   *parameterTable;
@property (retain) IBOutlet NSPanel       *saveAsDialog;
@property (retain) IBOutlet NSTextField   *saveAsField;
@property (retain) IBOutlet NSButton      *runInTerminalField;

@property (retain) NSMutableArray         *presets;
@property (retain,nonatomic) Preset                 *currentPreset;

#pragma mark -
#pragma mark Actions

- (IBAction)selectFilePressed:(id)sender;
- (IBAction)execute:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)saveAs:(id)sender;
- (IBAction)closeSaveAs:(id)sender;
- (IBAction)deletePreset:(id)sender;
- (IBAction)revert:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)selectPreset:(id)sender;
- (IBAction)fileFieldChanged:(id)sender;
- (IBAction)functionFieldChanged:(id)sender;
- (IBAction)modifyTablePressed:(id)sender;
- (IBAction)runInTerminalPressed:(id)sender;
- (IBAction)finishEditing:(id)sender;

#pragma mark -

- (id)initWithWindowNibName:(NSString*)nibName;
- (void)dealloc;
- (void)awakeFromNib;
- (void)updatePresetsPopUp;

#pragma mark -

- (void)saveAsDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (NSString*)pathForDataFile;
- (void)savePresets;
- (void)loadPresets;

@end
