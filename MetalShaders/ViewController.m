//
//  ViewController.m
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/27/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import "MetalView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MetalView *MetalView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)renderFragmentShader:(NSString*)shaderName {
    [self.MetalView configurePipelineWithFragmentShader:shaderName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showShaders"]) {
        [self.MetalView stopRender];
        ((TableViewController *)segue.destinationViewController).delegate = self;
    }
}

@end
