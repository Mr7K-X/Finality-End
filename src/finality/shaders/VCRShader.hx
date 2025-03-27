package finality.shaders;

import flixel.system.FlxAssets.FlxShader;

// coded by mrzkX
class VcrGlitchEffect
{
  public var shader(default, null):VcrGlitchShader = new VcrGlitchShader();

  public function new() {}

  var theTime:Float = 0;

  public function update(elapsed:Float)
  {
    theTime += elapsed;
  }
}

class VcrGlitchShader extends FlxShader
{
  @:glFragmentSource('
// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define BLOOM 1
#define CURVATURE 1
#define BLUR 1
#define BLACKLEVEL 1
#define SCANLINES 1
// 1: shadow mask
// 2: aperature grille
#define SHADOW_MASK 1
#define SHADOW_MASK_DARK 0.8
#define VIGNETTE 1

#define BLOOM_OFFSET            0.0015
#define BLOOM_STRENGTH          0.8

#define BLUR_MULTIPLIER         1.05
#define BLUR_STRENGTH           0.2
#define BLUR_OFFSET             0.003

#define BLACKLEVEL_FLOOR        TINT_COLOR / 40.0

#define CURVE_INTENSITY         1.0

#define SHADOW_MASK_STRENGTH    0.15

#define VIGNETTE_STRENGTH       1.2

#define TINT_COLOR              TINT_AMBER

#define TINT_AMBER              vec3(1.0, 0.7, 0.0) // P3 phosphor
#define TINT_LIGHT_AMBER        vec3(1.0, 0.8, 0.0)
#define TINT_GREEN_1            vec3(0.2, 1.0, 0.0)
#define TINT_APPLE_II           vec3(0.2, 1.0, 0.2) // P1 phosphor
#define TINT_GREEN_2            vec3(0.0, 1.0, 0.2)
#define TINT_APPLE_IIc          vec3(0.4, 1.0, 0.4) // P24 phpsphor
#define TINT_GREEN_3            vec3(0.0, 1.0, 0.4)
#define TINT_WARM               vec3(1.0, 0.9, 0.8)
#define TINT_COOL               vec3(0.8, 0.9, 1.0)

#define saturate(x) clamp(x, 0.0, 1.0)

float blurWeights[9] = float[](0.0, 0.092, 0.081, 0.071, 0.061, 0.051, 0.041, 0.031, 0.021);

#ifdef BLOOM
vec3 bloom(sampler2D sampler, vec3 color, vec2 uv) {
    vec3 bloom = color - texture(sampler, uv + vec2(-BLOOM_OFFSET, 0)).rgb;
    vec3 bloomMask = bloom * BLOOM_STRENGTH;

    return saturate(color + bloomMask);
}
#endif

#ifdef CURVATURE
vec2 transformCurve(vec2 uv) {
    uv -= 0.5;
    float r = (uv.x * uv.x + uv.y * uv.y) * CURVE_INTENSITY;
    uv *= 4.2 + r;
    uv *= 0.25;
    uv += 0.5;

    return uv;
}
#endif

#ifdef BLUR
vec3 blurH(sampler2D sampler, vec3 color, vec2 uv) {
    vec3 screen = texture(sampler, uv).rgb * 0.102;
    for (int i = 1; i < 9; i++) {
        screen += texture(sampler, uv + vec2(float(i) * BLUR_OFFSET, 0)).rgb * blurWeights[i];
    }

    for (int i = 1; i < 9; i++) {
        screen += texture(sampler, uv + vec2(float(-i) * BLUR_OFFSET, 0)).rgb * blurWeights[i];
    }

    return screen * BLUR_MULTIPLIER;
}

vec3 blurV(sampler2D sampler, vec3 color, vec2 uv) {
    vec3 screen = texture(sampler, uv).rgb * 0.102;
    for (int i = 1; i < 9; i++) {
        screen += texture(sampler, uv + vec2(0, float(i) * BLUR_OFFSET)).rgb * blurWeights[i];
    }

    for (int i = 1; i < 9; i++) {
        screen += texture(sampler, uv + vec2(0, float(-i) * BLUR_OFFSET)).rgb * blurWeights[i];
    }

    return screen * BLUR_MULTIPLIER;
}

vec3 blur(sampler2D sampler, vec3 color, vec2 uv) {
    vec3 blur = (blurH(sampler, color, uv) + blurV(sampler, color, uv)) / 2.0 - color;
    vec3 blurMask = blur * BLUR_STRENGTH;
    return saturate(color + blurMask);
}
#endif

#ifdef BLACKLEVEL
vec3 blacklevel(vec3 color) {
    color -= BLACKLEVEL_FLOOR;
    color = saturate(color);
    color += BLACKLEVEL_FLOOR;
    return color;
}
#endif

#ifdef SHADOW_MASK
vec3 shadowMask(vec2 uv, vec2 outputSize) {
    uv *= outputSize.xy;
    #if SHADOW_MASK == 1
    uv.x += uv.y * 3.0;
    vec3 mask = vec3(SHADOW_MASK_DARK);
    float x = fract(uv.x * (1.0 / 6.0));

    if(x < (1.0 / 3.0)) mask.r = 1.0;
    else if(x < (2.0 / 3.0)) mask.g = 1.0;
    else mask.b = 1.0;

    return mask;
    #elif SHADOW_MASK == 2
    vec3 mask = vec3(1.0);
    float x = fract(uv.x * (1.0 / 3.0));

    if(x < (1.0 / 3.0)) mask.r = SHADOW_MASK_DARK;
    else if(x < (2.0 / 3.0)) mask.g = SHADOW_MASK_DARK;
    else mask.b = SHADOW_MASK_DARK;

    return mask;
    #endif
}
#endif

vec3 crt(sampler2D sampler, vec2 uv, vec2 outputSize) {
    #ifdef CURVATURE
    uv = transformCurve(uv);

    if (uv.x < -0.0 || uv.y < -0.0 || uv.x > 1.0 || uv.y > 1.0) {
        return BLACKLEVEL_FLOOR;
    }
    #endif

    vec3 col = texture(sampler, uv).rgb;

    #ifdef BLOOM
    col = bloom(sampler, col, uv);
    #endif

    #ifdef BLUR
    col = blur(sampler, col, uv);
    #endif

    #ifdef BLACKLEVEL
    col = blacklevel(col);
    #endif

    #ifdef SCANLINES
    float s = 1.0 - smoothstep(320.0, 1440.0, outputSize.y) + 1.0;
    float j = cos(uv.y * outputSize.y * s) * 0.1;
    col = col - col * j;
    col *= 1.0 - (0.01 + ceil(mod((uv.x + 0.5) * outputSize.x, 3.0)) * (0.995 - 1.01));
    #endif

    #ifdef SHADOW_MASK
    col *= shadowMask(uv, outputSize);
    #endif


    #ifdef VIGNETTE
    vec2 vigUV = uv * (1.0 - uv.yx);
    float vignette = pow(vigUV.x * vigUV.y * 15.0, 0.25) * VIGNETTE_STRENGTH;
    col *= vignette;
    #endif

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;

    fragColor = vec4(crt(iChannel0, uv, iResolution.xy), texture(iChannel0, fragCoord / iResolution.xy).a);
}


void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}

    ')
  public function new()
  {
    super();
  }
}
