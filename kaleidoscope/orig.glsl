#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*0.5+.5)

#define time iTime
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
    vec2(12.9898,78.233)))
    * 43758.5453123);
}

float rand( vec2 p ) { return fract( sin( dot(p, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 + time * .35 ); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
    (c - a)* u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

const float pi = acos(-1.);
const float pi2 = pi * 2.;

vec3 lightDir = vec3(0.5, .5, -.5);

mat2 rot(float a){
	float s = sin(a), c = cos(a);
	return mat2(c, s, -s, c);
}

vec2 pmod(vec2 p, float d){
	float a = atan(p.x, p.y) + pi / d;
	float n = pi2 / d;
	a = floor(a / n) * n;
	return p * rot(-a);
}

float sdBox(vec3 p, vec3 b){
	vec3 d = abs(p) - b;
	return length(max(d, 0.)) + min(max(max(d.x, d.y), d.z), 0.);
}

float sdSphere(vec3 p, float r){
	return length(p) - r;
}

float map(vec3 p){
	
	p.xy = pmod(p.xy, 5.);
	p.y -= 2.;
    p.xy *= rot(time * .3);
		p.xz *= rot(time * .45);
	p.z = mod(p.z, 8.) - 4.;
	float d1 = sdBox(p, vec3(1., .3, .4));
	for(int i = 0; i< 4; i++){
		p = abs(p) - 1.;
		p.xy *= rot(time * .3);
		p.xz *= rot(time * .45);
	}
	d1 = min(d1, sdBox(p, vec3(1., .3, .4)));
	return d1;
}

vec3 genNormal(vec3 p){
	vec2 d = vec2(0.001, 0.);
	return normalize(vec3(
		map(p + d.xyy) - map(p - d.xyy),
		map(p + d.yxy) - map(p - d.yxy),
		map(p + d.yyx) - map(p - d.yyx)
		));
}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    
  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    
    
    
    {
    
        p=g*d;
      
             p.xz*=rot(iTime);
            p.xy*=rot(iTime);
               p.zy*=rot(iTime);    
         float normal = map(p);
         p.z*=5.*cos(iTime);
        a=20.+normal;
        p=mod(p-a,a*2.)-a;
        s=3.;
        for(int i=0;i++<8;){
      
            p=.3-abs(p);
            
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
       
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    70,
                    4.+cos(iTime*.5)*5.
                 )*normal;
         }
      
         g+=e=length(p.yx)/s;
    }
}