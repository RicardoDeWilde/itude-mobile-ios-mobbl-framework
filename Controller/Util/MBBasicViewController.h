//
//  MBBasicViewController.h
//  Core
//
//  Created by Wido on 6/2/10.
//  Copyright 2010 Itude Mobile BV. All rights reserved.
//

#import "MBViewControllerProtocol.h"

@class MBPage;

// This class is the ROOT of the MEMORY ALLOCATION STRUCTURE; the root of all retains.
// This class is pushed on UINavigationControllers or other controllers; when released it should trigger
// the release of MBPage, MBDocument and any other page related stuff.

@interface MBBasicViewController : UIViewController<MBViewControllerProtocol> {
	MBPage *_page;
}

@property (nonatomic, retain) MBPage *page;

- (void) rebuildView;
- (void) handleException:(NSException *) exception;
- (void) showActivityIndicator;
- (void) hideActivityIndicator;

@end