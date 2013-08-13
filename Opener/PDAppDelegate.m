//
//  PDAppDelegate.m
//  Opener
//
//  Created by nanao on 11/11/23.
//  Copyright (c) 2011 punchdrunker.org. All rights reserved.
//

#import "PDAppDelegate.h"
#import "RegexKitLite.h"
#import <NetFS/NetFS.h>

@implementation PDAppDelegate

@synthesize window = _window;
@synthesize urlField, openButoon, errorField;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.urlField = nil;
    self.openButoon = nil;
    self.errorField = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [NSApp setServicesProvider:self];
    NSUpdateDynamicServices();

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:NSControlTextDidChangeNotification
                                               object:nil];
}

// dockでクリックされた時に発火
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (![_window isVisible]) {
        [_window makeKeyAndOrderFront:nil];
    }
	return YES;
}

- (IBAction)showWindow:(id)sender {
    if (![_window isVisible]) {
        [_window makeKeyAndOrderFront:sender];
    }
}

-(IBAction)openButtonPushed:(id)sender {
    NSString *filePath = [urlField.stringValue stringByExpandingTildeInPath];
    if ([self openInFinder:filePath]) {
        [errorField setStringValue:@""];
        return;
    }
    
    // ¥マーク区切りのパスの場合はバックスラッシュパスとして扱う
    NSRange yenMarkRange = [filePath rangeOfString:@"¥¥"];
    if (yenMarkRange.location==0&&yenMarkRange.length==2) {
        filePath = [filePath stringByReplacingOccurrencesOfString:@"¥" withString:@"\\"];
    }
    
    // バックスラッシュパスの場合はマウント状況を確認して、対応するパスを探す
    NSRange range = [filePath rangeOfString:@"\\\\"];
    if (range.location==0&&range.length==2) {
        
        NSString *slashPath = [self findLocalPath:filePath];
        if (slashPath) {
            if ([self openInFinder:slashPath]) {
                [errorField setStringValue:@""];
                return;
            }
        }
        
        // パスが存在しなければ、マウントしてみる
        BOOL result = [self mountWithFilePath:filePath];
        if (result==YES) {
            slashPath = [self findLocalPath:filePath];
            if (slashPath) {
                if ([self openInFinder:slashPath]) {
                    [errorField setStringValue:@""];
                    return;
                }
            }
        }
        
    }
    NSString *errorMessage = NSLocalizedString(@"InvalidFilePath", @"Invalid file path");
    [errorField setStringValue:errorMessage];
}

-(BOOL)mountWithFilePath:(NSString *)path {
    return [self mountViaSamba:path];
}

-(BOOL)mountViaSamba:(NSString *)path {
    NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"\\"]];
    if ([pathArray count] < 4) {
        return NO;
    }
    // 先頭2つの要素は空文字なので飛ばす
    NSString *hostName = [pathArray objectAtIndex:2];
    NSString *mountPoint = [pathArray objectAtIndex:3];
    
    NSString *urlString = [NSString stringWithFormat:@"smb://%@/%@", [hostName lowercaseString], mountPoint];
    NSURL *url = [NSURL URLWithString:urlString];
    CFArrayRef mountpoints = NULL;
    int result = 0;
    result = NetFSMountURLSync((CFURLRef)url,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     &mountpoints
                                     );
    return (result==0);
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
 dfした結果からマウント中のdeviceを探す
 */
-(NSString *)findLocalPath:(NSString *)filePath {
    NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[filePath componentsSeparatedByString:@"\\"]];
    // 先頭2つの要素は空文字なので飛ばす
    NSString *hostName = [pathArray objectAtIndex:2];
    NSString *mountPoint;
    NSString *dfOutput = [self execCommand:@"/bin/df"];
    if (nil==dfOutput) return nil;
    
    NSArray *record = [dfOutput componentsSeparatedByString:@"\n"];
    
    // dfの結果を1行ごとに検証
    for (NSString *line in record) {
        NSArray *elements = [line componentsSeparatedByString:@" "];
        int count = (int)[elements count];
        NSString *mountName = [elements objectAtIndex:0];
        NSString *pattern = [NSString stringWithFormat:@"@%@(/|$)", [hostName lowercaseString]];
        
        // 与えられたパスからmacでのマウントポジションを探して、あればローカルのパスに置き換える
        NSRange range = [mountName rangeOfRegex:pattern];
        if (0<range.length) {
            mountPoint = [elements objectAtIndex:(count - 1)];
            NSString *mountHostName = [[mountName componentsSeparatedByString:@"@"] objectAtIndex:1];
            NSArray *splitedHostName = [mountHostName componentsSeparatedByString:@"/"];
            int count = (int)[splitedHostName count];
            NSRange removeRange;
            if (2<=count) {
                //マウントポジションよりも浅いパスの指定だった場合
                if ([pathArray count]<=3) {
                    removeRange = NSMakeRange(0, [pathArray count]);
                }
                else {
                    removeRange = NSMakeRange(0, 2 + count);
                }
            }
            else {
                removeRange = NSMakeRange(0, 2);
            }
            [pathArray removeObjectsInRange:removeRange];
            NSString *slashPath = [NSString stringWithFormat:@"%@/%@",
                                   mountPoint,
                                   [pathArray componentsJoinedByString:@"/"]];
            return slashPath;
        }
    }

    return nil;
}

-(NSString *)execCommand:(NSString *)command {
    NSTask *task = [[[NSTask alloc] init] autorelease];
    NSPipe *pipe = [NSPipe pipe];
    
    [task setLaunchPath:command];
    [task setStandardOutput:pipe];
    
    @try {
        [task launch];
    }
    @catch (NSException *ex) {
        NSLog(@"Exception: %@", [ex description]);
        return nil;
    }
    @finally {
    }
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle  readDataToEndOfFile];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark - NSTextFieldDelegate

// 改行を取り除く
- (BOOL)editingDidEnd:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    NSString *input = [urlField.stringValue stringByExpandingTildeInPath];
    NSString *pattern = [NSString stringWithFormat:@"\r|\n"];
    NSRange range = [input rangeOfRegex:pattern];
    if (0<range.length) {
        input = [input stringByReplacingOccurrencesOfRegex:pattern withString:@""];
        [urlField setStringValue:input];
    }
    
    return YES;
}

#pragma mark - Service Handler

- (void)requestService:(NSPasteboard *)pboard
              userData:(NSString *)userData
                 error:(NSString **)error
{
    NSArray *types = [pboard types];
    if (![types containsObject:NSPasteboardTypeString]) {
        *error = @"Error: could not get string";
        return;
    }

    NSString *filePath = [pboard stringForType:NSPasteboardTypeString];
    self.urlField.stringValue = filePath;
    [self openButtonPushed:self];
}

@end
