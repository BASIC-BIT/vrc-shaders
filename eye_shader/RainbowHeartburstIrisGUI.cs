using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

// Custom shader GUI for the Rainbow Heartburst Iris shader
public class RainbowHeartburstIrisGUI : ShaderGUI
{
    // Keep track of foldout states
    private bool showAnimationControls = true;
    private bool showParallaxControls = true;
    private bool showGlobalUVControls = true;
    
    // Material properties
    private MaterialProperty _EnableHeart;
    private MaterialProperty _EnableRainbow;
    private MaterialProperty _EnableNoise;
    private MaterialProperty _EnableSunburst;
    private MaterialProperty _EnableMirror;
    private MaterialProperty _RespondToLight;
    private MaterialProperty _EnableIrisDetail;
    private MaterialProperty _EnableLimbalRing;
    private MaterialProperty _EnableSparkle;
    private MaterialProperty _HeartPulseIntensity;
    private MaterialProperty _RingRotationSpeed;
    private MaterialProperty _GlobalParallaxStrength;
    private MaterialProperty _GlobalOffsetX;
    private MaterialProperty _GlobalOffsetY;
    private MaterialProperty _GlobalScaleX;
    private MaterialProperty _GlobalScaleY;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Find properties
        FindProperties(properties);
        
        // Get material
        Material material = materialEditor.target as Material;
        
        EditorGUILayout.Space();
        
        // Draw animation controls
        DrawAnimationControls(materialEditor, material);
        
        EditorGUILayout.Space();
        
        // Draw Global UV Controls
        DrawGlobalUVControls(materialEditor, material);
        
        EditorGUILayout.Space();
        
        // Draw Parallax Controls
        DrawParallaxControls(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Heart Pupil section
        DrawHeartPupilSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Rainbow Iris section
        DrawRainbowIrisSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Iris Detail section
        DrawIrisDetailSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Limbal Ring section
        DrawLimbalRingSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Noise section
        DrawNoiseSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Sparkle section
        DrawSparkleSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Sunburst section
        DrawSunburstSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Infinite Mirror section
        DrawMirrorSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Environment section
        DrawEnvironmentSection(materialEditor, material, properties);
    }

    private void FindProperties(MaterialProperty[] properties)
    {
        // Find toggle properties
        _EnableHeart = FindProperty("_EnableHeart", properties);
        _EnableRainbow = FindProperty("_EnableRainbow", properties);
        _EnableNoise = FindProperty("_EnableNoise", properties);
        _EnableSunburst = FindProperty("_EnableSunburst", properties);
        _EnableMirror = FindProperty("_EnableMirror", properties);
        _RespondToLight = FindProperty("_RespondToLight", properties);
        _EnableIrisDetail = FindProperty("_EnableIrisDetail", properties);
        _EnableLimbalRing = FindProperty("_EnableLimbalRing", properties);
        _EnableSparkle = FindProperty("_EnableSparkle", properties);
        _HeartPulseIntensity = FindProperty("_HeartPulseIntensity", properties);
        _RingRotationSpeed = FindProperty("_RingRotationSpeed", properties);
        _GlobalParallaxStrength = FindProperty("_GlobalParallaxStrength", properties);
        _GlobalOffsetX = FindProperty("_GlobalOffsetX", properties);
        _GlobalOffsetY = FindProperty("_GlobalOffsetY", properties);
        _GlobalScaleX = FindProperty("_GlobalScaleX", properties);
        _GlobalScaleY = FindProperty("_GlobalScaleY", properties);
    }
    
    // Helper method to draw a texture property with tiling and offset fields
    private void TexturePropertyWithTilingOffset(MaterialEditor materialEditor, GUIContent label, MaterialProperty textureProp, MaterialProperty tilingOffsetProp) 
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        
        // Draw the texture field
        materialEditor.TexturePropertySingleLine(label, textureProp);
        
        // Draw tiling and offset fields if the texture is assigned
        if (textureProp.textureValue != null) 
        {
            EditorGUI.indentLevel++;
            
            // Get the current tiling/offset value
            Vector4 tilingOffset = tilingOffsetProp.vectorValue;
            
            // Create fields for tiling
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Tiling");
            
            // Create fields for X and Y
            EditorGUI.BeginChangeCheck();
            float tilingX = EditorGUILayout.FloatField(tilingOffset.x);
            float tilingY = EditorGUILayout.FloatField(tilingOffset.y);
            if (EditorGUI.EndChangeCheck()) 
            {
                tilingOffset.x = tilingX;
                tilingOffset.y = tilingY;
                tilingOffsetProp.vectorValue = tilingOffset;
            }
            EditorGUILayout.EndHorizontal();
            
            // Create fields for offset
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Offset");
            
            // Create fields for X and Y offset
            EditorGUI.BeginChangeCheck();
            float offsetX = EditorGUILayout.FloatField(tilingOffset.z);
            float offsetY = EditorGUILayout.FloatField(tilingOffset.w);
            if (EditorGUI.EndChangeCheck()) 
            {
                tilingOffset.z = offsetX;
                tilingOffset.w = offsetY;
                tilingOffsetProp.vectorValue = tilingOffset;
            }
            EditorGUILayout.EndHorizontal();
            
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndVertical();
    }
    
    // Helper method to draw HSV controls
    private void DrawHSVControls(MaterialEditor materialEditor, MaterialProperty hueProp, MaterialProperty satProp, MaterialProperty brightProp)
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.LabelField("HSV Adjustment", EditorStyles.boldLabel);
        
        EditorGUI.indentLevel++;
        materialEditor.ShaderProperty(hueProp, "Hue Shift");
        materialEditor.ShaderProperty(satProp, "Saturation");
        materialEditor.ShaderProperty(brightProp, "Brightness");
        EditorGUI.indentLevel--;
        
        EditorGUILayout.EndVertical();
    }
    
    private void DrawGlobalUVControls(MaterialEditor materialEditor, Material material)
    {
        // Draw Global UV Controls header
        showGlobalUVControls = EditorGUILayout.BeginFoldoutHeaderGroup(showGlobalUVControls, "Global UV Controls");
        
        if (showGlobalUVControls)
        {
            EditorGUI.indentLevel++;
            
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Position", EditorStyles.boldLabel);
            
            // Position controls with reset button
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Offset");
            EditorGUI.BeginChangeCheck();
            float offsetX = EditorGUILayout.FloatField(_GlobalOffsetX.floatValue);
            float offsetY = EditorGUILayout.FloatField(_GlobalOffsetY.floatValue);
            
            if (GUILayout.Button("Reset", GUILayout.Width(50)))
            {
                offsetX = 0;
                offsetY = 0;
            }
            
            if (EditorGUI.EndChangeCheck())
            {
                _GlobalOffsetX.floatValue = offsetX;
                _GlobalOffsetY.floatValue = offsetY;
            }
            EditorGUILayout.EndHorizontal();
            
            // Scale controls with reset button
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Scale");
            EditorGUI.BeginChangeCheck();
            float scaleX = EditorGUILayout.FloatField(_GlobalScaleX.floatValue);
            float scaleY = EditorGUILayout.FloatField(_GlobalScaleY.floatValue);
            
            if (GUILayout.Button("Reset", GUILayout.Width(50)))
            {
                scaleX = 1.0f;
                scaleY = 1.0f;
            }
            
            if (EditorGUI.EndChangeCheck())
            {
                _GlobalScaleX.floatValue = scaleX;
                _GlobalScaleY.floatValue = scaleY;
            }
            EditorGUILayout.EndHorizontal();
            
            EditorGUILayout.EndVertical();
            
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawAnimationControls(MaterialEditor materialEditor, Material material)
    {
        // Draw animation controls header
        showAnimationControls = EditorGUILayout.BeginFoldoutHeaderGroup(showAnimationControls, "Animation Controls");
        
        if (showAnimationControls)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(_HeartPulseIntensity, "Heart Pulse Intensity");
            materialEditor.ShaderProperty(_RingRotationSpeed, "Ring Rotation Speed");
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawParallaxControls(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Draw parallax controls header
        showParallaxControls = EditorGUILayout.BeginFoldoutHeaderGroup(showParallaxControls, "Parallax Controls");
        
        if (showParallaxControls)
        {
            EditorGUI.indentLevel++;
            
            // Global parallax strength affects all effects
            materialEditor.ShaderProperty(_GlobalParallaxStrength, "Global Strength");
            
            // Specific effect parallax strengths
            materialEditor.ShaderProperty(FindProperty("_RainbowParallaxStrength", properties), "Rainbow Strength");
            
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawHeartPupilSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableHeart.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Heart Pupil", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableHeart.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_HEART", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            
            // Draw texture with tiling/offset
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.HelpBox("Heart texture provides both the shape (alpha) and color (RGB).", MessageType.Info);
            
            TexturePropertyWithTilingOffset(
                materialEditor, 
                new GUIContent("Heart Texture"), 
                FindProperty("_HeartTexture", properties),
                FindProperty("_HeartTextureTiling", properties)
            );
            EditorGUILayout.EndVertical();
            
            materialEditor.ShaderProperty(FindProperty("_HeartPupilColor", properties), "Heart Color Tint");
            
            // Draw HSV controls
            DrawHSVControls(
                materialEditor,
                FindProperty("_HeartHue", properties),
                FindProperty("_HeartSaturation", properties),
                FindProperty("_HeartBrightness", properties)
            );
            
            // Draw heart-specific noise controls
            EditorGUILayout.Space();
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Heart Noise Effect", EditorStyles.boldLabel);
            
            // Toggle for enabling heart noise
            MaterialProperty enableHeartNoise = FindProperty("_EnableHeartNoise", properties);
            materialEditor.ShaderProperty(enableHeartNoise, "Enable Heart Noise");
            
            // Only show noise parameters if noise is enabled
            if (enableHeartNoise.floatValue > 0.5f)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(FindProperty("_HeartNoiseIntensity", properties), "Noise Intensity");
                materialEditor.ShaderProperty(FindProperty("_HeartNoiseScale", properties), "Noise Scale");
                materialEditor.ShaderProperty(FindProperty("_HeartNoiseSpeed", properties), "Noise Speed");
                materialEditor.ShaderProperty(FindProperty("_HeartDynamicNoise", properties), "Dynamic Flow");
                EditorGUI.indentLevel--;
            }
            
            EditorGUILayout.EndVertical();
            
            // Size & Position controls
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Size & Position", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_HeartPupilSize", properties), "Heart Size");
            materialEditor.ShaderProperty(FindProperty("_HeartPositionX", properties), "Position X");
            materialEditor.ShaderProperty(FindProperty("_HeartPositionY", properties), "Position Y");
            materialEditor.ShaderProperty(FindProperty("_HeartBlendMode", properties), "Blend Mode");
            materialEditor.ShaderProperty(FindProperty("_HeartGradientAmount", properties), "Gradient Amount");
            
            // Add new parallax controls
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Parallax Settings", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_HeartParallaxStrength", properties), "Parallax Strength");
            materialEditor.ShaderProperty(FindProperty("_HeartParallaxHeight", properties), "Parallax Height");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawRainbowIrisSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableRainbow.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Rainbow Iris", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableRainbow.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_RAINBOW", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            materialEditor.TexturePropertySingleLine(new GUIContent("Rainbow Gradient"), FindProperty("_RainbowGradientTex", properties));
            
            // Draw HSV controls
            DrawHSVControls(
                materialEditor,
                FindProperty("_RainbowHue", properties),
                FindProperty("_RainbowSaturation", properties),
                FindProperty("_RainbowBrightness", properties)
            );
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Pattern Settings", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_RingCount", properties), "Ring Count");
            materialEditor.ShaderProperty(FindProperty("_IrisSparkleIntensity", properties), "Sparkle Intensity");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawIrisDetailSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableIrisDetail.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Iris Detail", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableIrisDetail.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_IRIS_DETAIL", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            
            // Draw texture with tiling/offset
            TexturePropertyWithTilingOffset(
                materialEditor, 
                new GUIContent("Iris Texture"), 
                FindProperty("_IrisTexture", properties),
                FindProperty("_IrisTextureTiling", properties)
            );
            
            materialEditor.ShaderProperty(FindProperty("_IrisTextureIntensity", properties), "Texture Intensity");
            materialEditor.ShaderProperty(FindProperty("_IrisTextureContrast", properties), "Texture Contrast");
            
            // Pattern settings
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Pattern Settings", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_IrisRadialPattern", properties), "Radial Pattern Mode");
            materialEditor.ShaderProperty(FindProperty("_IrisPatternRotation", properties), "Pattern Rotation");
            materialEditor.ShaderProperty(FindProperty("_IrisDetailParallax", properties), "Detail Parallax");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawLimbalRingSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableLimbalRing.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Limbal Ring", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableLimbalRing.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_LIMBAL_RING", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            
            materialEditor.ShaderProperty(FindProperty("_LimbalRingColor", properties), "Ring Color");
            
            // Draw HSV controls
            DrawHSVControls(
                materialEditor,
                FindProperty("_LimbalRingHue", properties),
                FindProperty("_LimbalRingSaturation", properties),
                FindProperty("_LimbalRingBrightness", properties)
            );
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Size Settings", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_LimbalRingWidth", properties), "Ring Width");
            materialEditor.ShaderProperty(FindProperty("_LimbalRingSoftness", properties), "Ring Softness");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawNoiseSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableNoise.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Noise Effects", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableNoise.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_NOISE", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            
            // Draw texture with tiling/offset
            TexturePropertyWithTilingOffset(
                materialEditor, 
                new GUIContent("Noise Texture"), 
                FindProperty("_NoiseTexture", properties),
                FindProperty("_NoiseTextureTiling", properties)
            );
            
            materialEditor.ShaderProperty(FindProperty("_IrisNoiseIntensity", properties), "Noise Intensity");
            materialEditor.ShaderProperty(FindProperty("_IrisNoiseScale", properties), "Noise Scale");
            
            // Advanced flow settings
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Flow Animation", EditorStyles.boldLabel);
            
            materialEditor.ShaderProperty(FindProperty("_NoiseFlowSpeed", properties), "Flow Speed");
            materialEditor.ShaderProperty(FindProperty("_DynamicNoiseMovement", properties), "Dynamic Flow Movement");
            
            // Only show distortion settings if dynamic flow is enabled
            if (material.GetFloat("_DynamicNoiseMovement") > 0.5f)
            {
                materialEditor.ShaderProperty(FindProperty("_NoiseDistortionScale", properties), "Flow Distortion Scale");
                materialEditor.ShaderProperty(FindProperty("_NoiseDistortionAmount", properties), "Flow Distortion Amount");
            }
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawSparkleSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableSparkle.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Sparkle Effects", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableSparkle.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_SPARKLE", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            
            materialEditor.ShaderProperty(FindProperty("_SparkleColor", properties), "Sparkle Color");
            
            // Draw HSV controls
            DrawHSVControls(
                materialEditor,
                FindProperty("_SparkleHue", properties),
                FindProperty("_SparkleSaturation", properties),
                FindProperty("_SparkleBrightness", properties)
            );
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Pattern Settings", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(FindProperty("_SparkleScale", properties), "Sparkle Scale");
            materialEditor.ShaderProperty(FindProperty("_SparkleSpeed", properties), "Sparkle Speed");
            materialEditor.ShaderProperty(FindProperty("_SparkleAmount", properties), "Sparkle Amount");
            materialEditor.ShaderProperty(FindProperty("_SparkleSharpness", properties), "Sparkle Sharpness");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawSunburstSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableSunburst.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Sunburst Streaks", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableSunburst.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_SUNBURST", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_SunburstLayerCount", properties), "Layer Count");
            materialEditor.ShaderProperty(FindProperty("_SunburstRotationSpeed", properties), "Rotation Speed");
            materialEditor.ShaderProperty(FindProperty("_SunburstIntensity", properties), "Streak Intensity");
            EditorGUI.indentLevel--;
        }
    }

    private void DrawMirrorSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _EnableMirror.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Infinite Mirror", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _EnableMirror.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_ENABLE_MIRROR", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_InfiniteDepthStrength", properties), "Depth Strength");
            materialEditor.ShaderProperty(FindProperty("_InfiniteBlurStrength", properties), "Blur Strength");
            materialEditor.ShaderProperty(FindProperty("_InfiniteLayerCount", properties), "Layer Count");
            
            // Add mirror-specific parallax control
            materialEditor.ShaderProperty(FindProperty("_InfiniteParallaxStrength", properties), "Parallax Strength");
            
            EditorGUI.indentLevel--;
        }
    }

    private void DrawEnvironmentSection(MaterialEditor materialEditor, Material material, MaterialProperty[] properties)
    {
        // Use the toggle as the section header
        bool toggleValue = _RespondToLight.floatValue > 0.5f;
        EditorGUILayout.BeginHorizontal();
        bool newToggleValue = EditorGUILayout.ToggleLeft("Environment", toggleValue, EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        
        // Update shader keyword if toggle changed
        if (newToggleValue != toggleValue)
        {
            _RespondToLight.floatValue = newToggleValue ? 1.0f : 0.0f;
            SetKeyword(material, "_RESPOND_TO_LIGHT", newToggleValue);
        }
        
        // Draw properties if enabled
        if (newToggleValue)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_EnvironmentLightingAmount", properties), "Lighting Amount");
            EditorGUI.indentLevel--;
        }
    }

    // Helper method to set shader keywords
    private void SetKeyword(Material material, string keyword, bool state)
    {
        if (state)
            material.EnableKeyword(keyword);
        else
            material.DisableKeyword(keyword);
    }
} 