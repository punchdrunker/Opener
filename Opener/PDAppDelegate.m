//
//  PDAppDelegate.m
//  Opener
//
//  Created by nanao on 11/11/23.
//  Copyright (c) 2011 punchdrunker.org. All rights reserved.
//

#import "PDAppDelegate.h"

@implementation PDAppDelegate

@synthesize window = _window;
@synthesize urlField, openButoon, errorField;

- (void)dealloc {
    urlField = nil;
    openButoon = nil;
    errorField = nil;
    
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

-(IBAction)openButtonPushed:(id)sender {
    NSLog(@"%s", __func__);
    NSString *filePath = [urlField.stringValue stringByExpandingTildeInPath];
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath
                    isDirectory:&isDirectory];
    if (isExist) {
        [[NSWorkspace sharedWorkspace] selectFile:isDirectory?nil:filePath 
                         inFileViewerRootedAtPath:isDirectory?filePath:nil];
    }
    else {
        [errorField setStringValue:@"無効なファイルパスです"];
    }
}

@end
