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
    NSString *filePath = [urlField.stringValue stringByExpandingTildeInPath];
    if ([self openInFinder:filePath]) {
        [errorField setStringValue:@""];
        return;
    }
    
    // バックスラッシュパスの場合はマウント状況を確認して、対応するパスを探してみる
    NSRange range = [filePath rangeOfString:@"\\\\"];
    if (range.location==0&&range.length==2) {
        NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[filePath componentsSeparatedByString:@"\\"]];
        NSString *hostName = [pathArray objectAtIndex:2];
        NSString *mountPoint = [self findMountPoint:hostName];
        if (mountPoint!=nil) {
            [pathArray removeObjectsInRange:NSMakeRange(0, 3)];
            NSString *localPath = [NSString stringWithFormat:@"%@/%@",mountPoint, [pathArray componentsJoinedByString:@"/"]];
            if ([self openInFinder:localPath]) {
                [errorField setStringValue:@""];
                return;
            }
        }
    }
    
    [errorField setStringValue:@"無効なファイルパスです"];
    
}

/* 
 pathを渡すと存在するかを確認してopenし、YESを返す
 存在しなければNOを返す
 */
-(BOOL)openInFinder:(NSString *)path {
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path
                                                        isDirectory:&isDirectory];
    if (isExist) {
        [[NSWorkspace sharedWorkspace] selectFile:isDirectory?nil:path 
                         inFileViewerRootedAtPath:isDirectory?path:nil];
        return YES;
    }
    else {
        return NO;
    }
}

/* 
 dfした結果からマウント中のdeviceを探してみる
 */
-(NSString *)findMountPoint:(NSString *)hostName {
    NSString *mountPoint;
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

        NSRange range = [[elements objectAtIndex:0] rangeOfString:hostName];
        if (0<range.length) {
            mountPoint = [elements objectAtIndex:(count - 1)];
            NSLog(@"mnt point: %@", mountPoint);            
        }
    }
    
    [task release];
    [pipe release];
    return mountPoint;
}

@end