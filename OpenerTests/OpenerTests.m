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

- (void)testDeleteNewLines
{
    NSString *input = @"\n/Test/Path/With/NewLinew \n\r\n\n";
    NSString *expect = @"/Test/Path/With/NewLinew ";
    STAssertEqualObjects([_opener deleteNewLines: input], expect, @"delete newlines");
}

- (void)testTrim
{
    NSString *input = @"\n/Test/Path/With/NewLinew \n\r\n\n";
    NSString *expect = @"/Test/Path/With/NewLinew";

    STAssertEqualObjects([_opener trim:input], expect, @"delete spaces and newlines");
}

@end
