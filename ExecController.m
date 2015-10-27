//
//  ExecController.m
//  Python
//
//  Created by Stephan Witoszynskyj on 19.12.11.
//  Copyright 2011 Stephan Witoszynskyj. All rights reserved.
//

#import "ExecController.h"
#import "Parameter.h"

//static 	NSString* const pythonTemplate = @"import sys\nsys.path.append('%@')\n\nimport %@ as mymod\n\nparams = dict([s.split('=') for s in sys.argv[1:]])\nmymod.%@(**params)\n";
static 	NSString* const pythonTemplate = @"import sys\nsys.path.append('%@')\n\nimport %@ as mymod\n\nmymod.%@(%@)\n";


@implementation ExecController

@synthesize presetsPopUp;
@synthesize fileField;
@synthesize functionField;
@synthesize parameterTable;
@synthesize saveAsDialog;
@synthesize saveAsField;
@synthesize runInTerminalField;

@synthesize presets;
@synthesize currentPreset;

#pragma mark -
#pragma mark Actions

- (IBAction)selectFilePressed:(id)sender {
	NSArray *fileTypes = [NSArray arrayWithObjects:@"py", nil];
	
	NSOpenPanel *openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanCreateDirectories:NO];
    [openDlg setAllowedFileTypes:fileTypes];
    
	if ([openDlg runModal] == NSOKButton) {
        [fileField setStringValue:[[openDlg URL] path]];
	}
}

- (IBAction)execute:(id)sender {
	[self finishEditing:sender];
	
	NSString *pyPath = [currentPreset.pyFile stringByDeletingLastPathComponent];
	NSString *pyFile = [currentPreset.pyFile lastPathComponent];
	NSString *pyMod  = [pyFile stringByDeletingPathExtension];
	NSString *pyExt  = [pyFile pathExtension];
	
	if ([pyPath isEqual:@""]) 
		pyPath = @".";
	
	if (! [pyExt isEqual:@"py"]) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Execute"];
		[alert setInformativeText:[NSString stringWithFormat:@"Cannot execute!\nPython file extension is missing in \"%@”!",pyFile]];
		[alert runModal];
		[alert release];
		
		return;
	}
		
	NSFileManager *fm = [NSFileManager defaultManager];
    if (! [fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",pyPath,pyFile]]) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Execute"];
		[alert setInformativeText:[NSString stringWithFormat:@"Cannot execute!\n\"%@/%@\" does not exist!",pyPath,pyFile]];
		[alert runModal];
		[alert release];
		
		return;
	}
	
	
	NSArray *currentSelection = [[BrowserController currentBrowser] databaseSelection];
	if ([currentSelection count] == 0) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Execute"];
		[alert setInformativeText:[NSString stringWithFormat:@"Cannot execute!\nNo studies/series selected!"]];
		[alert runModal];
		[alert release];
		
		return;
	}
	
	NSMutableArray *files = [NSMutableArray array];
	
	for (id selection in currentSelection) {
		if ([[[selection entity] name] isEqualToString:@"Study"]) {
			for (id series in [selection valueForKey:@"series"]) {
				for (id image in [series valueForKey:@"images"]) {
					[files addObject:[image valueForKey:@"completePath"]];
				}
			}
		} else {
			for (id image in [selection valueForKey:@"images"]) {
				[files addObject:[image valueForKey:@"completePath"]];
			}
			
		}

	}
	
	NSString *key   = @"";
	NSString *value = @""; 
	char first;
	char last;
	NSLocale *l_en               = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale: l_en];
	[formatter setAllowsFloats: YES];
	
	NSMutableArray *pyParams = [NSMutableArray array];
	for (id param in currentPreset.parameters) {
		key   = [param name];
		value = [param value];
		
		first = last = 0;
		
		if ([value length] > 1) {
			first = [value characterAtIndex:0];
			last  = [value characterAtIndex:([value length]-1)];
			
		}
		
		if (! ((first == '[' && last == ']') || (first == '{' && last == '}') || 
			   (first == '(' && last == ')') || (first == '"' && last == '"') || 
			   (first == '\'' && last == '\'') || [formatter numberFromString: value])) {
			value = [NSString stringWithFormat:@"'%@'",value];
		}
		
		[pyParams addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
	}
	[pyParams addObject:[NSString stringWithFormat:@"files=['%@']",
						 [files componentsJoinedByString:@"','"]]];
	
	
	NSString *pyCode = [NSString stringWithFormat:pythonTemplate,pyPath,pyMod,currentPreset.function,
						[pyParams componentsJoinedByString:@","]];
	
	// CREATE A TEMPORARY PYTHON FILE AND EXECUTE IT
	NSString *tempDirTemplate          = [NSTemporaryDirectory() 
										  stringByAppendingPathComponent:@"osirix-python-XXXXXX"];
	const char *tempDirTemplateCString = [tempDirTemplate fileSystemRepresentation];
	char *tempDirNameCString           = (char *) malloc(strlen(tempDirTemplateCString) + 1);
	strcpy(tempDirNameCString, tempDirTemplateCString);
	
	if (mkdtemp(tempDirNameCString) == NULL) {
		free(tempDirNameCString);
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Execute"];
		[alert setInformativeText:@"Couldn't create temporary directory!"];
		[alert runModal];
		[alert release];
		
		return;
	}

	NSString *tempDirName    = [NSString stringWithUTF8String:tempDirNameCString];
	NSString *tempFileName   = [tempDirName stringByAppendingPathComponent:@"script.py"];
	[pyCode writeToFile:tempFileName atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    
	NSString *command        = [NSString stringWithFormat:@"cd '%@'; python script.py; exit", tempDirName];
	NSAppleScript *script    = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell Application \"Terminal\" to do script \"%@\"", command]];
	NSDictionary *error;
	[script executeAndReturnError:&error];
	[script release];
	
	[formatter release];
	[l_en release];
	free(tempDirNameCString);	
}

- (IBAction)save:(id)sender {
	[self finishEditing:sender];
	if (currentPreset.name == nil) {
		[self saveAs:sender];
		return;
	}
	[self savePresets];
}

- (IBAction)saveAs:(id)sender {
	[self finishEditing:sender];
	
	[NSApp beginSheet:saveAsDialog
	   modalForWindow:[self window] modalDelegate:self
	   didEndSelector:@selector(saveAsDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)closeSaveAs:(id)sender {
	[saveAsDialog orderOut:self];
	[NSApp endSheet:saveAsDialog returnCode:([sender tag] == 1) ? NSOKButton : NSCancelButton];
	
}

- (IBAction)deletePreset:(id)sender {
	[self finishEditing:sender];
	
	int idx = [presetsPopUp indexOfSelectedItem];
	if (idx <= 0) 
		return;
	
	self.presets = [NSMutableArray arrayWithArray:presets];
	
	[self.presets removeObjectAtIndex:idx];
	
	[self savePresets];
	
	[self updatePresetsPopUp];
	self.currentPreset = [self.presets objectAtIndex:0];
}


- (IBAction)revert:(id)sender {
	[currentPreset revertToSaved];
	self.currentPreset = currentPreset;
	
}

- (IBAction)cancel:(id)sender {
	[self close];
}

- (IBAction)selectPreset:(id) sender {
	self.currentPreset = [self.presets objectAtIndex:[presetsPopUp indexOfSelectedItem]];
}

- (IBAction)fileFieldChanged:(id)sender {
	currentPreset.pyFile = [fileField stringValue];
}

- (IBAction)functionFieldChanged:(id)sender {
	currentPreset.function = [functionField stringValue];
}

- (IBAction)modifyTablePressed:(id)sender {
	
	switch ([sender selectedSegment]) {
		case 0: {
				Parameter *parameter = [[[Parameter alloc] init] autorelease];
			
				[currentPreset.parameters addObject:parameter];
				[parameterTable reloadData];
			
				NSInteger columnIdx = [parameterTable columnWithIdentifier:@"name"];
				[parameterTable editColumn:columnIdx row:[currentPreset.parameters indexOfObject:parameter] withEvent:nil select:YES];
			}
			break;
		case 1:
			if ([parameterTable numberOfSelectedRows] > 0) {
				[currentPreset.parameters removeObjectsAtIndexes:[parameterTable selectedRowIndexes]];
				[parameterTable reloadData];
			}
		default:
			break;
	}
}

- (IBAction)runInTerminalPressed:(id)sender {
	currentPreset.runInTerminal = [runInTerminalField state];
}

- (IBAction)finishEditing:(id)sender {
	[self fileFieldChanged:sender];
	[self functionFieldChanged:sender];
	[self runInTerminalPressed:sender];
}

#pragma mark -

- (id)initWithWindowNibName:(NSString*)nibName {
	if (self = [super initWithWindowNibName:nibName]) {
		[self loadPresets];
	}
	
	return self;
}

- (void)dealloc {
	self.presets       = nil;
	self.currentPreset = nil;
	
	[super dealloc];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self updatePresetsPopUp];
}

- (void)updatePresetsPopUp {
	
	[presetsPopUp removeAllItems];
	 
	for (id preset in self.presets) {
		NSString *name = [preset name];
		if (name == nil) {
			name = @"New preset";
		}
		
		[presetsPopUp addItemWithTitle:name];
	}
}

- (void)setCurrentPreset:(Preset *)preset {
	currentPreset = preset;
	
	[fileField setStringValue:currentPreset.pyFile];
	[functionField setStringValue:currentPreset.function];
	[parameterTable reloadData];
	[runInTerminalField setState:currentPreset.runInTerminal];
	
	NSMenuItem *menuItem = [presetsPopUp itemWithTitle:preset.name];
	if (menuItem == nil) 
		[presetsPopUp selectItemAtIndex:0];
	else
		[presetsPopUp selectItem:menuItem];
}

#pragma mark -
#pragma mark Datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView {
	return self.currentPreset.parameters.count;
}

- (id)tableView:(NSTableView*)table objectValueForTableColumn:(NSTableColumn*)column row:(NSInteger)row {
	Parameter *parameter  = [currentPreset.parameters objectAtIndex:row];
	NSString *identifier = column.identifier;
	if ([identifier isEqualTo:@"name"]) {
		return parameter.name;
	} 
	
	return parameter.value;
}

- (void)tableView:(NSTableView*)table setObjectValue:(id)object forTableColumn:(NSTableColumn*)column row:(NSInteger)row {
	Parameter *parameter  = [currentPreset.parameters objectAtIndex:row];
	NSString *identifier = column.identifier;
	if ([identifier isEqualTo:@"name"]) {
		parameter.name = object;
	} else {
		parameter.value = object;
	}
}

#pragma mark -
- (void)saveAsDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSCancelButton) return;
	
	NSString *newPresetName = [saveAsField stringValue];
	
	if ([newPresetName isEqual:@""]) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Save Preset As"];
		[alert setInformativeText:@"A name is required! Preset not saved!"];
		[alert runModal];
		[alert release];
		
		return;
	}
	
	for (id preset in self.presets) {
		if ([newPresetName isEqual:[preset name]]) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:@"Save Preset As"];
			[alert setInformativeText:@"A preset with this name exists already! Preset not saved!"];
			[alert runModal];
			[alert release];
			
			return;
		}
	}
	
	Preset *newPreset = [[[Preset alloc] initWithPreset:currentPreset] autorelease];
	newPreset.name = newPresetName;
	[currentPreset revertToSaved];
	
	[self.presets addObject:newPreset];
	[self savePresets];
	
	[self updatePresetsPopUp];
	
	self.currentPreset = newPreset;
}

- (NSString*)pathForDataFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/OsiriX/Plugins/Python";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO) {
		[fileManager createDirectoryAtPath: folder withIntermediateDirectories:YES attributes: nil  error:nil];
	}
    
	NSString *fileName = @"pythonPresets";
	return [folder stringByAppendingPathComponent: fileName];    
}

- (void)savePresets {
	NSString *path = [self pathForDataFile];
	
	NSMutableDictionary *rootObject;
	rootObject = [NSMutableDictionary dictionary];
    
	[rootObject setValue: self.presets forKey:@"presets"];
	[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
}

- (void)loadPresets {
	NSString     *path       = [self pathForDataFile];
	NSDictionary *rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path]; 
	self.presets             = [rootObject valueForKey:@"presets"];
	
	if (! self.presets) {
		self.presets       = [[NSMutableArray alloc] init];
		[self.presets insertObject:[[[Preset alloc] init] autorelease] atIndex:0];
	}
	[self updatePresetsPopUp];
	
	self.currentPreset = [self.presets objectAtIndex:0];
}

@end
