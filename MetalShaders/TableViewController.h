//
//  TableViewController.h
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/30/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MetalViewControllerDelegate.h"

@interface TableViewController : UITableViewController

@property (strong,nonatomic) id<MetalViewControllerDelegate> delegate;

@end
