//
//  ViewController.h
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/27/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalViewControllerDelegate.h"

@interface ViewController : UIViewController <MetalViewControllerDelegate>

- (void)renderFragmentShader:(NSString*)shaderName;

@end

