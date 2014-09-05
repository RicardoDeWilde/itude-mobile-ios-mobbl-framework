//
//  MBFileManagerTest.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 14/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBResourceService.h"

NSString * const ReadingTestFileName    =   @"MBFileManagerReadTest.xml";
NSString * const WritingTestFileName    =   @"MBFileManagerWriteTest.xml";

NSString * const TestContentsString     =   @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                            @"<root>\n"
                                            @"    <child>value</child>\n"
                                            @"</root>";

@interface MBFileManagerTest : XCTestCase

@end

@implementation MBFileManagerTest

- (MBFileManager *)fileManager {
    MBResourceService *resourceService = [MBResourceService sharedInstance];
    MBFileManager *fileManager = resourceService.fileManager;

    return fileManager;
}

- (NSData *)testData {
    return [TestContentsString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
}

- (void) testDataWithContentsOfMainBundle {
    NSData *dataReadFromFile = [[self fileManager] dataWithContentsOfMainBundle:ReadingTestFileName];
    
    NSData *expectedData = [self testData];
    
    XCTAssertEqualObjects(dataReadFromFile, expectedData);
}

- (void) testWriteContents {
    [[self fileManager] writeContents:TestContentsString toFileName:WritingTestFileName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    
    NSString *absoluteFilePath = [documentDirectory stringByAppendingPathComponent:WritingTestFileName];
    
    NSData *dataReadFromFile = [NSData dataWithContentsOfFile:absoluteFilePath];
    NSData *expectedData = [self testData];
    
    XCTAssertEqualObjects(dataReadFromFile, expectedData);
}

@end
