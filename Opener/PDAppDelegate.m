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
    [self executeDfCommand];
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
        [errorField setStringValue:@""];
    }
    else {
        [errorField setStringValue:@"無効なファイルパスです"];
    }
}

-(void)executeDfCommand {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    [task setLaunchPath:@"/bin/df"];
    [task setStandardOutput:pipe];
    [task launch];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle  readDataToEndOfFile];
    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSArray *record = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in record) {
        NSArray *elements = [line componentsSeparatedByString:@" "];
        int count = (int)[elements count];
        NSLog(@"device: %@", [elements objectAtIndex:0]);
        NSLog(@"mnt point: %@", [elements objectAtIndex:(count - 1)]);
    }
    
    [task release];
    [pipe release];
}

- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
    NSLog(@"%s", __func__);
//    [self openButtonPushed:nil];
}

@end