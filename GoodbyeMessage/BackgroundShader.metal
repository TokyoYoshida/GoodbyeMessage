//
//  BackgroundShader.metal
//  GoodbyeMessage
//
//  Created by TokyoYoshida on 2020/07/30.
//  Copyright © 2020 TokyoMac. All rights reserved.
//
//  Quote from : http://glslsandbox.com/e#65865.2

#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>

struct GlobalData {
    float2 ch_pos;//   = float2 (0.0, 0.0);             // character position(X,Y)
    float d;// = 1e6;
    float time;
};


struct VertexInput {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float2 texCoords [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};

struct ColorInOut
{
    float4 position [[ position ]];
    float2 texCoords;
};

vertex ColorInOut vertexShader(VertexInput          in       [[ stage_in ]],
                               constant NodeBuffer& scn_node [[ buffer(0) ]])
{
    ColorInOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.texCoords = in.texCoords;
    
    return out;
}


float snow(float2 uv,float scale, float time)
{
    float ptime = time / 32.;
    float w=smoothstep(1.,0.,-uv.y*(scale/10.));if(w<.1)return 0.;
    uv+=ptime/scale;uv.y+=ptime*2./scale;uv.x+=sin(uv.y+ptime*.5)/scale;
    uv*=scale;float2 s=floor(uv),f=fract(uv),p=0;float k=3.,d;
    p=.5+.35*sin(11.*fract(sin((s+p+scale)*float2x2(float2(7,3),float2(6,5)))*5.))-f;d=length(p);k=min(d,k);
    k=smoothstep(0.,k,sin(f.x+f.y)*0.01);
    return k*w;
}

float2 toPolar(float2 p, float time) {
  return float2(length(p)*sin(time*.1), atan2(p.y, p.x))*sin(time*.1);
}


float4 render(float2 gl_FragCoord, float2 resolution, float time) {
    float2 uv = ( gl_FragCoord.xy / resolution.xy )*4.0;

//    float2 uv0=uv;
    float i0=1.2;
    float i1=0.95;
    float i2=1.5;
    float2 i4=float2(0.0,0.0);
    float2 mouse = float2(1,1);

    for(int s=0;s<10;s++)
    {
        float2 r;
        r=float2(cos(uv.y*i0-i4.y+mouse.x/i1),sin(uv.x*i0+i4.x+mouse.y/i1))/i2;
        r+=float2(-r.y,r.x)*0.2;
        uv.xy+=r;
        
        i0*=1.93;
        i1*=1.25;
        i2*=1.7;
        i4+=r.xy*1.0+0.5*time*i1;
    }
    float r=sin(uv.x-time)*0.5+0.5;
    float b=sin(uv.y+time)*0.5+0.5;
    float g=sin((sqrt(uv.x*uv.x+uv.y*uv.y)+time))*0.5+0.5;
    float3 cc=float3(r,g,b);
    
    return float4(cc,1.0);
}






// Because for some reason this isn't a part of glsl
float clamp01(float v) { return clamp(v, 0.,1.); }
float2 clamp01(float2 v) { return clamp(v, 0.,1.); }
float3 clamp01(float3 v) { return clamp(v, 0.,1.); }
float4 clamp01(float4 v) { return clamp(v, 0.,1.); }
//float2 uv;

constant float2 ch_size  = float2(1.0, 2.0);              // character size (X,Y)
constant float2 ch_space = ch_size + float2(1.0, 1.0);    // character distance Vector(X,Y)
constant float2 ch_start = float2 (0);
#define REPEAT_SIGN false // True/False; True=Multiple, False=Single

/* 16 segment display...Akin to LED Display.

Segment bit positions:
  __2__ __1__
 |\    |    /|
 | \   |   / |
 3  11 10 9  0
 |   \ | /   |
 |    \|/    |
  _12__ __8__
 |           |
 |    /|\    |
 4   / | \   7
 | 13 14  15 |
 | /   |   \ |
  __5__|__6__

15 12 11 8 7  4 3  0
 |  | |  | |  | |  |
 0000 0000 0000 0000

example: letter A

   12    8 7  4 3210
    |    | |  | ||||
 0001 0001 1001 1111

 binary to hex -> 0x119F
*/

#define n0 ddigit(0x22FF, uv, globalData);
#define n1 ddigit(0x0281, uv, globalData);
#define n2 ddigit(0x1177, uv, globalData);
#define n3 ddigit(0x11E7, uv, globalData);
#define n4 ddigit(0x5508, uv, globalData);
#define n5 ddigit(0x11EE, uv, globalData);
#define n6 ddigit(0x11FE, uv, globalData);
#define n7 ddigit(0x2206, uv, globalData);
#define n8 ddigit(0x11FF, uv, globalData);
#define n9 ddigit(0x11EF, uv, globalData);

#define A ddigit(0x119F, uv, globalData);
#define B ddigit(0x927E, uv, globalData);
#define C ddigit(0x007E, uv, globalData);
#define D ddigit(0x44E7, uv, globalData);
#define E ddigit(0x107E, uv, globalData);
#define F ddigit(0x101E, uv, globalData);
#define G ddigit(0x807E, uv, globalData);
#define H ddigit(0x1199, uv, globalData);
#define I ddigit(0x4466, uv, globalData);
#define J ddigit(0x4436, uv, globalData);
#define K ddigit(0x9218, uv, globalData);
#define L ddigit(0x0078, uv, globalData);
#define M ddigit(0x0A99, uv, globalData);
#define N ddigit(0x8899, uv, globalData);
#define O ddigit(0x00FF, uv, globalData);
#define P ddigit(0x111F, uv, globalData);
#define Q ddigit(0x80FF, uv, globalData);
#define R ddigit(0x911F, uv, globalData);
#define S ddigit(0x8866, uv, globalData);
#define T ddigit(0x4406, uv, globalData);
#define U ddigit(0x00F9, uv, globalData);
#define V ddigit(0x2218, uv, globalData);
#define W ddigit(0xA099, uv, globalData);
#define X ddigit(0xAA00, uv, globalData);
#define Y ddigit(0x4A00, uv, globalData);
#define Z ddigit(0x2266, uv, globalData);
#define _ globalData->ch_pos.x += ch_space.x;
#define _h ch_pos.x += ch_space.x * .5;

#define s_dot     ddigit(0, uv, globalData);
#define s_minus   ddigit(0x1100, uv, globalData);
#define s_plus    ddigit(0x5500, uv, globalData);
#define s_greater ddigit(0x2800, uv, globalData);
#define s_less    ddigit(0x8200, uv, globalData);
#define s_sqrt    ddigit(0x0C02, uv, globalData);


#define cr ch_pos.x = ch_start.x;
#define lf ch_pos.y -= 3.0;
#define lf_h ch_pos.y -= 1.0;

#define nl ch_pos.x = ch_start.x; ch_pos.y -= 3.0;
#define nl_h ch_pos.x = ch_start.x; ch_pos.y -= 1.0;

#define nl0 ch_pos = ch_start;
#define nl1 ch_pos = ch_start;  ch_pos.y -= 3.0;
#define nl2 ch_pos = ch_start;  ch_pos.y -= 6.0;
#define nl3 ch_pos = ch_start;    ch_pos.y -= 9.0;

float dseg(float2 p0, float2 p1, float2 uv, device GlobalData *globalData)
{
    float2 dir = normalize(p1 - p0);
    float2 cp = (uv - globalData->ch_pos - p0) * float2x2(float2(dir.x, dir.y),float2(-dir.y, dir.x));
    return distance(cp, clamp(cp, float2(0), float2(distance(p0, p1), 0)));
}

bool bit(int n, int b)
{
    return fmod(floor(float(n) / exp2(floor(float(b)))) , 2.0) != 0.0;
}


void ddigit(int n, float2 uv, device GlobalData *globalData)
{
    float v = 1e6;
    if (n == 0)     v = min(v, dseg(float2(-0.405, -1.000), float2(-0.500, -1.000),uv, globalData));
    if (bit(n,  0)) v = min(v, dseg(float2( 0.500,  0.063), float2( 0.500,  0.937),uv, globalData));
    if (bit(n,  1)) v = min(v, dseg(float2( 0.438,  1.000), float2( 0.063,  1.000),uv, globalData));
    if (bit(n,  2)) v = min(v, dseg(float2(-0.063,  1.000), float2(-0.438,  1.000),uv, globalData));
    if (bit(n,  3)) v = min(v, dseg(float2(-0.500,  0.937), float2(-0.500,  0.062),uv, globalData));
    if (bit(n,  4)) v = min(v, dseg(float2(-0.500, -0.063), float2(-0.500, -0.938),uv, globalData));
    if (bit(n,  5)) v = min(v, dseg(float2(-0.438, -1.000), float2(-0.063, -1.000),uv, globalData));
    if (bit(n,  6)) v = min(v, dseg(float2( 0.063, -1.000), float2( 0.438, -1.000),uv, globalData));
    if (bit(n,  7)) v = min(v, dseg(float2( 0.500, -0.938), float2( 0.500, -0.063),uv, globalData));
    if (bit(n,  8)) v = min(v, dseg(float2( 0.063,  0.000), float2( 0.438, -0.000),uv, globalData));
    if (bit(n,  9)) v = min(v, dseg(float2( 0.063,  0.063), float2( 0.438,  0.938),uv, globalData));
    if (bit(n, 10)) v = min(v, dseg(float2( 0.000,  0.063), float2( 0.000,  0.937),uv, globalData));
    if (bit(n, 11)) v = min(v, dseg(float2(-0.063,  0.063), float2(-0.438,  0.938),uv, globalData));
    if (bit(n, 12)) v = min(v, dseg(float2(-0.438,  0.000), float2(-0.063, -0.000),uv, globalData));
    if (bit(n, 13)) v = min(v, dseg(float2(-0.063, -0.063), float2(-0.438, -0.938),uv, globalData));
    if (bit(n, 14)) v = min(v, dseg(float2( 0.000, -0.938), float2( 0.000, -0.063),uv, globalData));
    if (bit(n, 15)) v = min(v, dseg(float2( 0.063, -0.063), float2( 0.438, -0.938),uv, globalData));
    globalData->ch_pos.x += ch_space.x;
    globalData->d = min(globalData->d, v);
}

constant float4x4 text = float4x4(
    float4(2.5, .5, 2.5, 2.5),
    float4(2.5, .32, 1.5, 4.5),
    float4(1.5, 11.2, 1.5, 2.5),
    float4(1, 1, 6, .05)
);


float cf(float2 uv, float4 p, float ts, float time) {
    return (p.x + p.z + sin(ts*p.y*time+p.y*(uv.y+uv.x)) * p.z) * p.w;
}
float3 cc_(float2 uv, float4x4 m, float ts, float time) {
    float4 f = m[3];
    return abs(f.a *
               float3(f.r*cf(uv, m[0], ts, time),
                f.g*cf(uv, m[1], ts, time),
                f.b*cf(uv, m[2], ts, time)));
}
float3 cc(float2 uv, float4x4 m, float time) { return cc_(uv, m, 1.0, time); }

float3 dblend(float3 c, float v, float2 m) {
    return clamp01((1.0-m.x*v) * c)
        + clamp01(mix(c, float3(0,0,0), 1.0 - (m.y / v)));
}




float4 renderText( float2 gl_FragCoord ,float2 resolution, float time, float2 uv, device GlobalData *globalData) {
    //d = 1e6;
    float2 aspect = resolution.xy / resolution.y;
    uv = ( gl_FragCoord.xy / resolution.y ) - aspect / 2.0;
    uv *= 20.0;
    uv.x += 5.*sin(time);
    
    uv = float2(.1*sin(time)*uv.x*uv.y + uv.x,  .1*cos(time)*uv.x*uv.y + uv.y);

    
_ I _ A M _ Y O U _
    
    
    float3 textc = cc(uv, text, time);
    
    float3 color = float3(0, 0, 0);
    
    color += 1. * dblend(textc, globalData->d, float2(3.40282347E+38, .1));
    
    return float4(color, 1.0);
}

// Converted from https://www.shadertoy.com/view/XsXXDn
float4 playgroundSample(ColorInOut in,
                             float time,
                             device GlobalData *globalData) { // 当該スレッドが処理中のピクセルの２次元座標（左上が原点） ushort2は ushortが２つパックされたもの
    int width = 1000;//o.get_width(); // 幅を得る
    int height = 1000;//o.get_height(); // 高さを得る
    float2 gl_FragCoord = float2(in.position.xy);
    float2 resolution = float2(width, height); //
    float2 position = ( gl_FragCoord.xy / resolution.xy );
    
    position = toPolar(position, time);
    
    float ptime = 0.001*(time/4.-length(position-.5));
    
    float2 uv = position;
    float c = 0.;
        c+=snow(uv,30.*sin(ptime),time);
        c+=snow(uv,15.*cos(ptime),time);
        c+=snow(uv,10.*sin(ptime),time);
        c+=snow(uv,8.*cos(ptime),time);
        c+=snow(uv,6.*sin(ptime),time);
        c+=snow(uv,5.*cos(ptime),time);

    constexpr sampler colorSampler;
    //    float4 back=texture2D( backbuffer, fract(float2(1,-1)/resolution+position+0.1*(5.-fract(time/256.+uv.x/2.))*snow(uv+snow(uv+snow(uv,5.,time),8.,time),30.,time)) );
    float4 back=float4(fract(float2(1,-1)/resolution+position+0.1*(5.-fract(time/256.+uv.x/2.))*snow(uv+snow(uv+snow(uv,5.,time),8.,time),30.,time)),0,1);
//    float4 back=readTexture.sample(colorSampler, fract(float2(1,-1)/resolution+position+0.1*(5.-fract(time/256.+uv.x/2.))*snow(uv+snow(uv+snow(uv,5.,time),8.,time),30.,time)));
//    float4 back=float4(0,0,0,0);

    float4 front=back*.98 - float4(1.-float(fract(ptime)<0.5),1.+float(fract(ptime)<0.5),1.+float(fract(ptime)<0.5)*10.,1)/256. +  float4(c);
    
    float4 colors = render(gl_FragCoord, resolution, time);
    float4 result = colors * front + renderText(gl_FragCoord, resolution, time, uv, globalData);
    return result;
}


fragment float4 fragmentShader(ColorInOut in          [[ stage_in] ],
                               device GlobalData &globalData [[buffer(1)]]
                               )
{
    float2 uv = in.texCoords * 4;
    float time =globalData.time;
    float i0=1.2;
    float i1=0.95;
    float i2=1.5;
    float2 i4=float2(0.0,0.0);
    for(int s=0;s<4;s++)
    {
        float2 r;
        r=float2(cos(uv.y*i0-i4.y+time/i1),sin(uv.x*i0+i4.x+time/i1))/i2;
        r+=float2(-r.y,r.x)*0.2;
        uv.xy+=r;
        
        i0*=1.93;
        i1*=1.25;
        i2*=1.7;
        i4+=r.xy*1.0+0.5*time*i1;
    }
    float r=sin(uv.x-time)*0.5+0.5;
    float b=sin(uv.y+time)*0.5+0.5;
    float g=sin((sqrt(uv.x*uv.x+uv.y*uv.y)+time))*0.5+0.5;
    half3 c=half3(r,g,b);
    GlobalData data;
    float4 ret = playgroundSample(in, time, &globalData);
    return ret;//half4(c,1.0);
}


