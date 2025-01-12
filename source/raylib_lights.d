// quantumde1 developed software, licensed under BSD-0-Clause license.
module raylib_lights;

extern(C) {
    // Include the necessary raylib types
    import raylib; // Make sure to import raylib types like Vector3, Color, Shader, etc.

    // Define the Light struct
    struct Light {
        int type;
        bool enabled;
        Vector3 position;
        Vector3 target;
        Color color;
        float attenuation;
        int enabledLoc;
        int typeLoc;
        int positionLoc;
        int targetLoc;
        int colorLoc;
        int attenuationLoc;
    }

    // Define the LightType enum
    enum LightType {
        LIGHT_DIRECTIONAL = 0,
        LIGHT_POINT
    }
}

static int lightsCount = 0;    // Current amount of created lights

// Send light properties to shader
// NOTE: Light shader locations should be available 
void UpdateLightValues(Shader shader, Light light)
{
    // Send to shader light enabled state and type
    SetShaderValue(shader, light.enabledLoc, &light.enabled, ShaderUniformDataType.SHADER_UNIFORM_INT);
    SetShaderValue(shader, light.typeLoc, &light.type, ShaderUniformDataType.SHADER_UNIFORM_INT);

    // Send to shader light position values
    float[3] position = [ light.position.x, light.position.y, light.position.z ];
    SetShaderValue(shader, light.positionLoc, &position, ShaderUniformDataType.SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    float[3] target = [ light.target.x, light.target.y, light.target.z ];
    SetShaderValue(shader, light.targetLoc, &target, ShaderUniformDataType.SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    float[4] color = [ cast(float)light.color.r/cast(float)255, cast(float)light.color.g/cast(float)255, 
                       cast(float)light.color.b/cast(float)255, cast(float)light.color.a/cast(float)255 ];
    SetShaderValue(shader, light.colorLoc, &color, ShaderUniformDataType.SHADER_UNIFORM_VEC4);
}
// Create a light and get shader locations
Light CreateLight(int type, Vector3 position, Vector3 target, Color color, Shader shader)
{
    Light light = { 0 };

    light.enabled = true;
    light.type = type;
    light.position = position;
    light.target = target;
    light.color = color;

    // NOTE: Lighting shader naming must be the provided ones
    light.enabledLoc = GetShaderLocation(shader, TextFormat("lights[%i].enabled", lightsCount));
    light.typeLoc = GetShaderLocation(shader, TextFormat("lights[%i].type", lightsCount));
    light.positionLoc = GetShaderLocation(shader, TextFormat("lights[%i].position", lightsCount));
    light.targetLoc = GetShaderLocation(shader, TextFormat("lights[%i].target", lightsCount));
    light.colorLoc = GetShaderLocation(shader, TextFormat("lights[%i].color", lightsCount));

    UpdateLightValues(shader, light);
    
    lightsCount++;
    return light;
}
