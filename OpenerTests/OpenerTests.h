//
//  OpenerTests.h
//  OpenerTests
//
//  Created by nanao on 2013/04/11.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "PDAppDelegate.h"

@interface OpenerTests : SenTestCase {
    @private
    PDAppDelegate * _opener;
}
- (void)testFindLocalPath;
@end