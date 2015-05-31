//
//  MetalViewControllerDelegate.h
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/30/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

@protocol MetalViewControllerDelegate <NSObject>

- (void)renderFragmentShader:(NSString*)shaderName;

@end
