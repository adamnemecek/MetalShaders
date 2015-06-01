//
//  shader.metal
//  MetalShaders
//
//  Created by Lixuan Zhu on 5/29/15.
//  Copyright (c) 2015 Lixuan Zhu. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct ColoredVertex {
    float4 position [[position]];
    float4 color;
};

struct FragmentUniforms
{
    float2 resolution;
    float time;
};


// Vertex Shader
vertex ColoredVertex vertex_main(constant float4 *position [[buffer(0)]],
                                 constant float4 *color [[buffer(1)]],
                                 uint vertexID [[vertex_id]]) {
    ColoredVertex coloredVertex;
    coloredVertex.position = position[vertexID];
    coloredVertex.color = color[vertexID];
    return coloredVertex;
}

// Fragment Shader
fragment float4 fragment_main(ColoredVertex coloredVertex [[stage_in]]) {
    return coloredVertex.color;
}

// First Shader
fragment float4 fragment_main_1(ColoredVertex coloredVertex [[stage_in]],
                                constant FragmentUniforms *uniforms [[buffer(0)]]) {

    float2 resolution = uniforms->resolution;
    float t = uniforms->time;

    float4 color = float4(coloredVertex.position.x/resolution.x, coloredVertex.position.y/resolution.y,cos(3.1415*t),1.0);
    return color;
}

// Second Shader
fragment float4 fragment_main_2(ColoredVertex coloredVertex [[stage_in]],
                                 constant FragmentUniforms *uniforms [[buffer(0)]]) {
    float4 coordinates = coloredVertex.position;
    float4 color = float4(0.0,coordinates.xy-floor(coordinates.xy),1.0);

    return color;
}

// Third Shader
fragment float4 sierpinski_main(ColoredVertex coloredVertex [[stage_in]],
                                constant FragmentUniforms *uniforms [[buffer(0)]]) {
    float t = uniforms->time;
    float2 coordinates = coloredVertex.position.xy;
    float2 resolution = uniforms->resolution;

    float s = 0.1*max(0.0,sin(3.1415*t));
    float2 uv = coordinates.xy/resolution;

    float f = 1.0;
    for (int i = 0; i < 3; i++) {
        //f *= 1.0 - step(abs(abs(uv.x-0.5)-0.2),0.1-s)*step(abs(abs(uv.y-0.5)-0.2),0.1-s);
        f *= 1- step(sqrt(pow(abs(uv.x-0.5)-0.25,2.0)+pow(abs(uv.y-0.5)-0.25,2.0)),s);

        uv = fract(uv*4.0); // this scale the whole uv down by factor of 5
    }

    return float4(f,f,f,1.0);
}

// Forth Shader

float distanceToSphere(float3 p, float r) {
    return length(p)-r;
}

float distanceToGroundPlane(float3 p) {
    return p.y+0.5;
}

float distanceToCube(float3 p) {
    return length(max(abs(p)-float3(0.5,0.5,0.5),0.0));
}

float distanceToObjects(float3 p, float t) {
    float d1 = distanceToSphere(p,0.5*max(0.0,sin(0.5*3.1415*t)));
    float d2 = distanceToGroundPlane(p);
    float d3 = distanceToSphere(p+(-1)*float3(0.5,0,0.5),0.5*max(0.0,sin(0.7*3.1415*t)));

    float a = -3.1415/6;
    float3x3 R = float3x3(float3(cos(a),0.0,-sin(a)),
                          float3(0.0   ,1.0,    0.0),
                          float3(sin(a),0.0, cos(a)));

    float d4 = distanceToCube(R*(p+(-1)*float3(-0.4,0,0)));

    return min(d1,min(d2,min(d3,d4)));
}

float4 rayCast(float3 ro, float3 rd, float time) {
    float4 color = float4(1.0,1.0,1.0,1.0);
    float4 color1 = float4(0.0,1.0,0.2,1.0);
    float4 color2 = float4(0.0,0.2,1.0,1.0);

    float t = 0.0;
    const int N = 100;
    for (int i = 0; i < N; i++) {
        float3 p = ro+t*rd;
        float d = distanceToObjects(p,time);
        if (d < 0.01) {
            color = mix(color1,color2,float(i)/float(N));
            break;
        }
        else {
            t += d;
        }
    }
    return color;
}

fragment float4 ray_cast_main(ColoredVertex coloredVertex [[stage_in]],
                                constant FragmentUniforms *uniforms [[buffer(0)]]) {
    float t = uniforms->time;
    float2 coordinates = coloredVertex.position.xy;
    float2 resolution = uniforms->resolution;

    float2 uv = 2.0*(coordinates/resolution)-1.0;
    uv[0] *= resolution.x/resolution.y;
    uv[1] = -uv[1];

    float3 C_o = float3(0.0,0.0,0.0);
    float3 C_x = float3(1.0,0.0,0.0);
    float3 C_y = float3(0.0,1.0,0.0);
    float3 C_z = float3(0.0,0.0,1.0);
    float f = 2.0;

    float3 T = float3(0,0,4);
    float3x3 R = float3x3(float3(1.0,0.0,0.0),
                          float3(0.0,1.0,0.0),
                          float3(0.0,0.0,1.0));

    float3 ray_o = uv[0]*C_x+uv[1]*C_y-f*C_z;
    float3 ray_dir = normalize(ray_o);

    float3 ray_o_g = R*ray_o+T;
    float3 ray_dir_g = R*ray_dir;

    return rayCast(ray_o_g,ray_dir_g,t);
}



