//
//  CollectionViewController.h
//  Restaurant
//
//  Created by Alex on 12/14/12.
//
//

#import <Foundation/Foundation.h>
#import "GettingCoreContent.h"

@interface CollectionViewController : UICollectionViewController<UISplitViewControllerDelegate>

@property (nonatomic, strong) GettingCoreContent *db;

@end
