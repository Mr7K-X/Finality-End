package finality.shaders;

import flixel.system.FlxAssets.FlxShader;

class VignetteShader extends FlxShader
{
  @:glFragmentSource('
#pragma header
#pragma format R8G8B8A8_SRGB

#define NTSC_CRT_GAMMA 1.5
#define NTSC_MONITOR_GAMMA 1.0

#define TWO_PHASE
#define COMPOSITE
//#define THREE_PHASE
// #define SVIDEO

// begin params
#define PI 3.14159265

#if defined(TWO_PHASE)
	#define CHROMA_MOD_FREQ (1.0 * PI / 1.0)
#elif defined(THREE_PHASE)
	#define CHROMA_MOD_FREQ (PI / 1.0)
#endif

#if defined(COMPOSITE)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 1.0
	#define FRINGING 1.0
#elif defined(SVIDEO)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 0.0
	#define FRINGING 0.0
#endif
// end params

uniform int uFrame;
uniform float uInterlace;

// fragment compatibility #defines

#if defined(COMPOSITE) || defined(SVIDEO)
mat3 mix_mat = mat3(
	BRIGHTNESS, FRINGING, FRINGING,
	ARTIFACTING, 1.0 * SATURATION, 0.0,
	ARTIFACTING, 0.0, 1.0 * SATURATION
);
#endif

// begin ntsc-rgbyuv
const mat3 yiq2rgb_mat = mat3(
	1.0, 0.956, 0.6210,
	1.0, -0.2720, -0.6474,
	1.0, -1.1060, 1.7046);

vec3 yiq2rgb(vec3 yiq)
{
	return yiq * yiq2rgb_mat;
}

const mat3 yiq_mat = mat3(
	0.2989, 0.5870, 0.1140,
	0.5959, -0.2744, -0.3216,
	0.2115, -0.5229, 0.3114
);

vec3 rgb2yiq(vec3 col)
{
	return col * yiq_mat;
}
// end ntsc-rgbyuv

//#define TAPS 32
float luma_filter[33];
float chroma_filter[33];

vec4 pass1(vec2 uv)
{
	vec2 fragCoord = uv * openfl_TextureSize;

	vec4 cola = texture2D(bitmap, uv).rgba;
	vec3 yiq = rgb2yiq(cola.rgb);

	#if defined(TWO_PHASE)
		float chroma_phase = PI * (mod(fragCoord.y, 2.0) + float(uFrame));
	#elif defined(THREE_PHASE)
		float chroma_phase = 0.6667 * PI * (mod(fragCoord.y, 3.0) + float(uFrame));
	#endif

	float mod_phase = chroma_phase + fragCoord.x * CHROMA_MOD_FREQ;

	float i_mod = cos(mod_phase);
	float q_mod = sin(mod_phase);

	if(uInterlace == 1.0) {
		yiq.yz *= vec2(i_mod, q_mod); // Modulate.
		yiq *= mix_mat; // Cross-talk.
		yiq.yz *= vec2(i_mod, q_mod); // Demodulate.
	}
	return vec4(yiq, cola.a);
}

vec4 fetch_offset(vec2 uv, float offset, float one_x) {
	return pass1(uv + vec2((offset - 0.5) * one_x, 0.0)).xyzw;
}

void main()
{
	luma_filter[0] = -0.000174844;
	luma_filter[1] = -0.000205844;
	luma_filter[2] = -0.000149453;
	luma_filter[3] = -0.000051693;
	luma_filter[4] = 0.000000000;
	luma_filter[5] = -0.000066171;
	luma_filter[6] = -0.000245058;
	luma_filter[7] = -0.000432928;
	luma_filter[8] = -0.000472644;
	luma_filter[9] = -0.000252236;
	luma_filter[10] = 0.000198929;
	luma_filter[11] = 0.000687058;
	luma_filter[12] = 0.000944112;
	luma_filter[13] = 0.000803467;
	luma_filter[14] = 0.000363199;
	luma_filter[15] = 0.000013422;
	luma_filter[16] = 0.000253402;
	luma_filter[17] = 0.001339461;
	luma_filter[18] = 0.002932972;
	luma_filter[19] = 0.003983485;
	luma_filter[20] = 0.003026683;
	luma_filter[21] = -0.001102056;
	luma_filter[22] = -0.008373026;
	luma_filter[23] = -0.016897700;
	luma_filter[24] = -0.022914480;
	luma_filter[25] = -0.021642347;
	luma_filter[26] = -0.008863273;
	luma_filter[27] = 0.017271957;
	luma_filter[28] = 0.054921920;
	luma_filter[29] = 0.098342579;
	luma_filter[30] = 0.139044281;
	luma_filter[31] = 0.168055832;
	luma_filter[32] = 0.178571429;

	chroma_filter[0] = 0.001384762;
	chroma_filter[1] = 0.001678312;
	chroma_filter[2] = 0.002021715;
	chroma_filter[3] = 0.002420562;
	chroma_filter[4] = 0.002880460;
	chroma_filter[5] = 0.003406879;
	chroma_filter[6] = 0.004004985;
	chroma_filter[7] = 0.004679445;
	chroma_filter[8] = 0.005434218;
	chroma_filter[9] = 0.006272332;
	chroma_filter[10] = 0.007195654;
	chroma_filter[11] = 0.008204665;
	chroma_filter[12] = 0.009298238;
	chroma_filter[13] = 0.010473450;
	chroma_filter[14] = 0.011725413;
	chroma_filter[15] = 0.013047155;
	chroma_filter[16] = 0.014429548;
	chroma_filter[17] = 0.015861306;
	chroma_filter[18] = 0.017329037;
	chroma_filter[19] = 0.018817382;
	chroma_filter[20] = 0.020309220;
	chroma_filter[21] = 0.021785952;
	chroma_filter[22] = 0.023227857;
	chroma_filter[23] = 0.024614500;
	chroma_filter[24] = 0.025925203;
	chroma_filter[25] = 0.027139546;
	chroma_filter[26] = 0.028237893;
	chroma_filter[27] = 0.029201910;
	chroma_filter[28] = 0.030015081;
	chroma_filter[29] = 0.030663170;
	chroma_filter[30] = 0.031134640;
	chroma_filter[31] = 0.031420995;
	chroma_filter[32] = 0.031517031;


	vec2 uv = openfl_TextureCoordv;
	vec2 fragCoord = uv * openfl_TextureSize;

	float one_x = 1.0 / openfl_TextureSize.x;
	vec4 signal = vec4(0.0);

	for (int i = 0; i < /*TAPS*/32; i++)
	{
		float offset = float(i);

		vec4 sums = fetch_offset(uv, offset - float(/*TAPS*/32), one_x) * 2.;

		signal += sums * vec4(luma_filter[i], chroma_filter[i], chroma_filter[i], 1.0);
	}
	signal += pass1(uv - vec2(0.5 / openfl_TextureSize.x, 0.0)).xyzw *
		vec4(luma_filter[/*TAPS*/32], chroma_filter[/*TAPS*/32], chroma_filter[/*TAPS*/32], 1.0);

	vec3 rgb = yiq2rgb(signal.xyz);
	gl_FragColor = vec4(pow(rgb, vec3(NTSC_CRT_GAMMA / NTSC_MONITOR_GAMMA)), flixel_texture2D(bitmap, uv).a);
}
')
  public function new()
  {
    super();
  }
}
