uniform sampler2D baseTexture;
uniform sampler2D normalTexture;
uniform sampler2D textureFlags;
uniform sampler2D specialTexture;

uniform vec4 skyBgColor;
uniform float fogDistance;
uniform vec3 eyePosition;
uniform float animationTimer;

varying vec3 vPosition;
varying vec3 worldPosition;

varying vec3 normal;
varying vec3 tangent;
varying vec3 binormal;

varying vec3 eyeVec;
varying vec3 lightVec;

const float e = 2.718281828459;
const float BS = 10.0;

// Water normalmap code based on water shader by martinsh
// http://devlog-martinsh.blogspot.com/

float windSpeed = 1.0; //wind speed
float scale = 1.0; //overall wave scale
vec2 bigWaves = vec2(1.5, 1.0); //strength of big waves
vec2 midWaves = vec2(0.3, 0.15); //strength of middle sized waves
vec2 smallWaves = vec2(0.4, 0.3); //strength of small waves
float choppy = 0.05; //wave choppyness

void main(void)
{
	vec2 windDir = vec2(0.0, 0.0); //wind direction XY
	float x,y,z;
	x = 0.5 * worldPosition.x;
	y = 0.25 * worldPosition.y;
	z = 0.5 * worldPosition.z;
	vec2 uv = vec2 (x + y, z - y);
	float timer = animationTimer * 50.0;
	if (normal.x == 0.0 && normal.z == 0.0) 
		windDir = 0.7 * normalize(vec2(-binormal.x, -binormal.z));
	else if (binormal.x == 0.0 && binormal.z == 0.0)
		windDir = vec2 (4.5, -4.5);
	else 
		windDir = 4.5 * normalize(vec2(binormal.x, binormal.z));

   	//normal map
	vec2 nCoord = vec2(0.0, 0.0);
	nCoord = uv * (scale * 0.05) + windDir * timer * (windSpeed * 0.04);
	vec3 normal0 = 2.0 * texture2D(normalTexture,
		nCoord + vec2(-timer * 0.015, -timer * 0.005)).rgb - 1.0;
	nCoord = uv * (scale * 0.1) + windDir * timer * (windSpeed * 0.08)
		- (normal0.xy / normal0.zz) * choppy;
	vec3 normal1 = 2.0 * texture2D(normalTexture,
		nCoord + vec2(timer * 0.020, timer * 0.015)).rgb - 1.0;
	nCoord = uv * (scale * 0.25) + windDir * timer * (windSpeed*0.07)-(normal1.xy/normal1.zz)*choppy;
	vec3 normal2 = 2.0 * texture2D(normalTexture, nCoord + vec2(-timer*0.04,-timer*0.03)).rgb - 1.0;
	nCoord = uv * (scale * 0.5) + windDir * timer * (windSpeed*0.09)-(normal2.xy/normal2.z)*choppy;
	vec3 normal3 = 2.0 * texture2D(normalTexture, nCoord + vec2(+timer*0.03,+timer*0.04)).rgb - 1.0;
	nCoord = uv * (scale* 1.0) + windDir * timer * (windSpeed*0.4)-(normal3.xy/normal3.zz)*choppy;
	vec3 normal4 = 2.0 * texture2D(normalTexture, nCoord + vec2(-timer*0.02,+timer*0.1)).rgb - 1.0;  
	nCoord = uv * (scale * 2.0) + windDir * timer * (windSpeed*0.7)-(normal4.xy/normal4.zz)*choppy;
	vec3 normal5 = 2.0 * texture2D(normalTexture, nCoord + vec2(+timer*0.1,-timer*0.06)).rgb - 1.0;

	vec3 nVec = vec3(normalize(normal0 * bigWaves.x + normal1 * bigWaves.y +
							normal2 * midWaves.x + normal3 * midWaves.y +
							normal4 * smallWaves.x + normal5 * smallWaves.y));

	vec3 base = vec3(0.1, 0.51, 0.9);
	vec3 color = base * dot(-normalize(eyeVec), nVec);
	float alpha = clamp((color.r + color.b + color.g) * 1.5, 0.2, 0.65);
	vec4 col = vec4(color.rgb, 1.0);
	col *= gl_Color;
	col.a = alpha;
	gl_FragColor = vec4(col.rgba);
}
