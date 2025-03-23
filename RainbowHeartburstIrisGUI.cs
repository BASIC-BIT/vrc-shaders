using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

// Custom shader GUI for the Rainbow Heartburst Iris shader
public class RainbowHeartburstIrisGUI : ShaderGUI
{
    // Keep track of foldout states
    private bool showAnimationControls = true;
    private bool showParallaxControls = true;
    
    // Material properties
    private MaterialProperty _EnableHeart;
    private MaterialProperty _EnableRainbow;
    private MaterialProperty _EnableNoise;
    private MaterialProperty _EnableSunburst;
    private MaterialProperty _EnableMirror;
    private MaterialProperty _RespondToLight;
    private MaterialProperty _HeartPulseIntensity;
    private MaterialProperty _RingRotationSpeed;
    private MaterialProperty _GlobalParallaxStrength;

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
        
        // Draw Parallax Controls
        DrawParallaxControls(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Heart Pupil section
        DrawHeartPupilSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Rainbow Iris section
        DrawRainbowIrisSection(materialEditor, material, properties);
        
        EditorGUILayout.Space();
        
        // Draw Noise section
        DrawNoiseSection(materialEditor, material, properties);
        
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
        _HeartPulseIntensity = FindProperty("_HeartPulseIntensity", properties);
        _RingRotationSpeed = FindProperty("_RingRotationSpeed", properties);
        _GlobalParallaxStrength = FindProperty("_GlobalParallaxStrength", properties);
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
            materialEditor.TexturePropertySingleLine(new GUIContent("Heart Texture"), FindProperty("_HeartTexture", properties));
            materialEditor.ShaderProperty(FindProperty("_HeartPupilColor", properties), "Heart Color");
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
            materialEditor.ShaderProperty(FindProperty("_RingCount", properties), "Ring Count");
            materialEditor.ShaderProperty(FindProperty("_IrisSparkleIntensity", properties), "Sparkle Intensity");
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
            materialEditor.TexturePropertySingleLine(new GUIContent("Noise Texture"), FindProperty("_NoiseTexture", properties));
            materialEditor.ShaderProperty(FindProperty("_IrisNoiseIntensity", properties), "Noise Intensity");
            materialEditor.ShaderProperty(FindProperty("_IrisNoiseScale", properties), "Noise Scale");
            materialEditor.ShaderProperty(FindProperty("_IrisNoiseSpeed", properties), "Animation Speed");
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