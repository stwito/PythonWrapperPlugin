//
//  PythonFilter.h
//  Python
//
//  Copyright (c) 2011 Stephan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

@interface PythonFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

@end
