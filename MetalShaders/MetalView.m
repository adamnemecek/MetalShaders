//
//  MetalView.m
//  
//
//  Created by Lixuan Zhu on 5/27/15.
//
//

#import "MetalView.h"

@implementation MetalView

+ (id)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.metalLayer = (CAMetalLayer *)self.layer;
        self.device = MTLCreateSystemDefaultDevice();
        self.metalLayer.device = self.device;
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;

        [self buildVertexBuffers];
        [self buildPipeLine];
    }
    return self;
}

- (void)buildVertexBuffers {
    static const float positions[] = {-1.0, 1.0, 0, 1,
                                      -1.0,-1.0, 0, 1,
                                       1.0, 1.0, 0, 1,
                                       1.0, 1.0, 0, 1,
                                      -1.0,-1.0, 0, 1,
                                       1.0,-1.0, 0, 1,};

    static const float colors[] = {0.5, 0.5, 0.5, 1,
                                   0.5, 0.5, 0.5, 1,
                                   0.5, 0.5, 0.5, 1,
                                   0.5, 0.5, 0.5, 1,
                                   0.5, 0.5, 0.5, 1,
                                   0.5, 0.5, 0.5, 1};

    self.positionBuffer = [self.device newBufferWithBytes:positions
                                                   length:sizeof(positions)
                                                  options:MTLResourceOptionCPUCacheModeDefault];

    self.colorBuffer = [self.device newBufferWithBytes:colors
                                                length:sizeof(colors)
                                               options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)buildPipeLine {
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;

    self.pipleline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                 error:NULL];
}

- (void)didMoveToWindow {
    [super didMoveToSuperview];
    if (self.superview) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLinkCalled:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)onDisplayLinkCalled:(CADisplayLink *)displayLink {
    [self redraw];
}

- (void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;

    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.5, 0.5,1.0);

    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [encoder setRenderPipelineState:self.pipleline];
    [encoder setVertexBuffer:self.positionBuffer offset:0 atIndex:0];
    [encoder setVertexBuffer:self.colorBuffer offset:0 atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6 instanceCount:1];
    [encoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
