//
//  PDAppDelegate.h
//  Opener
//
//  Created by nanao on 11/11/23.
//  Copyright (c) 2011 punchdrunker.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PDAppDelegate : NSObject <NSApplicationDelegate>{
    NSTextField *urlField;
    NSTextField *errorField;
    NSButton *openButoon;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTextField *urlField;
@property (nonatomic, retain) IBOutlet NSTextField *errorField;
@property (nonatomic, retain) IBOutlet NSButton *openButoon;

-(IBAction)showWindow:(id)sender;
-(IBAction)openButtonPushed:(id)sender;
-(BOOL)openInFinder:(NSString *)path;
-(NSString *)findLocalPath:(NSString *)filePath;
-(NSString *)execCommand:(NSString *)command;
-(NSString *)deleteNewLines:(NSString *)string;
-(NSString *)expandTilde:(NSString *)string;
-(NSString *)trim:(NSString *)string;
@end
