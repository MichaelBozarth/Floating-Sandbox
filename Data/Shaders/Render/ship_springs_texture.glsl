###VERTEX

#version 120

#define in attribute
#define out varying

// Inputs
in vec2 inShipPointPosition;
in float inShipPointLight;
in float inShipPointWater;
in vec2 inShipPointTextureCoordinates;
in float inShipPointPlaneId;

// Outputs        
out float vertexLightIntensity;
out float vertexLightColorMix;
out float vertexWater;
out vec2 vertexTextureCoords;

// Params
uniform float paramAmbientLightIntensity;
uniform mat4 paramOrthoMatrix;

void main()
{            
    vertexLightIntensity = paramAmbientLightIntensity + (1.0 - paramAmbientLightIntensity) * inShipPointLight;
    vertexLightColorMix = inShipPointLight;
    vertexWater = inShipPointWater;
    vertexTextureCoords = inShipPointTextureCoordinates;

    gl_Position = paramOrthoMatrix * vec4(inShipPointPosition.xy, inShipPointPlaneId, 1.0);
}

###FRAGMENT

#version 120

#define in varying

// Inputs from previous shader        
in float vertexLightIntensity;
in float vertexLightColorMix;
in float vertexWater;
in vec2 vertexTextureCoords;

// Input texture
uniform sampler2D sharedSpringTexture;

// Params
uniform float paramWaterContrast;
uniform float paramWaterLevelThreshold;

void main()
{
    vec4 vertexCol = texture2D(sharedSpringTexture, vertexTextureCoords);

    // Discard transparent pixels, so that ropes (which are drawn temporally after
    // this shader but Z-ally behind) are not occluded by transparent triangles
    if (vertexCol.w < 0.2)
        discard;

    // Apply point water
    float colorWetness = min(vertexWater, paramWaterLevelThreshold) / paramWaterLevelThreshold * paramWaterContrast;
    vec4 fragColour = vertexCol * (1.0 - colorWetness) + vec4(%WET_COLOR_VEC4%) * colorWetness;

    // Apply light
    fragColour *= vertexLightIntensity;

    // Apply point light color
    fragColour = fragColour * (1.0 - vertexLightColorMix) + vec4(%LAMPLIGHT_COLOR_VEC4%) * vertexLightColorMix;
    
    gl_FragColor = vec4(fragColour.xyz, vertexCol.w);
} 
