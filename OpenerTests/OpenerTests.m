//
//  OpenerTests.m
//  OpenerTests
//
//  Created by nanao on 2013/04/11.
//
//

#import "OpenerTests.h"

@implementation OpenerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
     _opener = [[PDAppDelegate alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testFindLocalPath
{
    STAssertNil([_opener findLocalPath: @"\\\\test\\point"], @"hoge");
}

@end
