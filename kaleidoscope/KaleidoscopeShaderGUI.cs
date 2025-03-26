using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

// Custom shader GUI for the Kaleidoscope shader
public class KaleidoscopeShaderGUI : ShaderGUI
{
    // Foldout tracking
    private bool _showBaseSettings = true;
    private bool _showRotationSettings = true;
    private bool _showFractalSettings = true;
    private bool _showRaymarchSettings = true;
    private bool _showAnimationSettings = true;
    private bool _showAudioLinkSettings = true;
    private bool _showColorSettings = true;
    private bool _showPresets = false;

    // Presets definitions
    private struct ShaderPreset
    {
        public string Name;
        public Dictionary<string, float> FloatValues;
        public Dictionary<string, Color> ColorValues;
        public Dictionary<string, Vector4> VectorValues;
    }

    private readonly List<ShaderPreset> _presets = new List<ShaderPreset>
    {
        new ShaderPreset
        {
            Name = "Psychedelic",
            FloatValues = new Dictionary<string, float>
            {
                { "_RotationSpeedXY", 0.5f },
                { "_RotationSpeedXZ", 0.7f },
                { "_SymmetryCount", 8f },
                { "_FractalIterations", 8 },
                { "_ColorCycleSpeed", 0.5f },
                { "_ColorBlendAmount", 0.8f },
                { "_BassEffect", 4f }, // Color
                { "_MidEffect", 1f }, // Symmetry
                { "_HighEffect", 3f }, // Rotation
            },
            ColorValues = new Dictionary<string, Color>
            {
                { "_MainColor", new Color(1f, 0.2f, 0.8f) }
            }
        },
        new ShaderPreset
        {
            Name = "Cosmic",
            FloatValues = new Dictionary<string, float>
            {
                { "_RotationSpeedXY", 0.2f },
                { "_RotationSpeedXZ", 0.3f },
                { "_SymmetryCount", 5f },
                { "_FractalIterations", 6 },
                { "_Iterations", 150f },
                { "_StepSize", 0.8f },
                { "_FractalScale", 25f },
                { "_ZModFactor", 3f },
                { "_ColorCycleSpeed", 0.1f },
                { "_BassEffect", 2f }, // Scale
                { "_MidEffect", 4f }, // Color
                { "_HighEffect", 1f }, // Symmetry
            },
            ColorValues = new Dictionary<string, Color>
            {
                { "_MainColor", new Color(0.1f, 0.2f, 0.8f) }
            }
        },
        new ShaderPreset
        {
            Name = "Subtle Beat",
            FloatValues = new Dictionary<string, float>
            {
                { "_RotationSpeedXY", 0.1f },
                { "_RotationSpeedXZ", 0.15f },
                { "_SymmetryCount", 4f },
                { "_FractalIterations", 5 },
                { "_AnimationSpeed", 0.5f },
                { "_AudioLinkBassIntensity", 2.0f },
                { "_AudioLinkBeatMultiplier", 3.0f },
                { "_BassEffect", 3f }, // Rotation
                { "_MidEffect", 2f }, // Scale
                { "_HighEffect", 4f }, // Color
                { "_UseAudioLink", 1f },
            },
            ColorValues = new Dictionary<string, Color>
            {
                { "_MainColor", new Color(0.8f, 0.8f, 0.9f) }
            }
        },
        new ShaderPreset
        {
            Name = "Aggressive",
            FloatValues = new Dictionary<string, float>
            {
                { "_RotationSpeedXY", 0.8f },
                { "_RotationSpeedXZ", 1.2f },
                { "_SymmetryCount", 3f },
                { "_FractalIterations", 10 },
                { "_AnimationSpeed", 1.5f },
                { "_AudioLinkBassIntensity", 3.0f },
                { "_AudioLinkBeatMultiplier", 5.0f },
                { "_BassEffect", 2f }, // Scale
                { "_MidEffect", 3f }, // Rotation
                { "_HighEffect", 1f }, // Symmetry
                { "_UseAudioLink", 1f },
                { "_Contrast", 1.8f },
                { "_Brightness", 1.5f },
            },
            ColorValues = new Dictionary<string, Color>
            {
                { "_MainColor", new Color(1.0f, 0.1f, 0.1f) }
            }
        }
    };

    // Helper function for creating foldouts
    private bool DrawFoldout(string title, bool display)
    {
        var style = new GUIStyle("ShurikenModuleTitle");
        style.font = new GUIStyle(EditorStyles.boldLabel).font;
        style.border = new RectOffset(15, 7, 4, 4);
        style.fixedHeight = 22;
        style.contentOffset = new Vector2(20f, -2f);

        var rect = GUILayoutUtility.GetRect(16f, 22f, style);
        GUI.Box(rect, title, style);

        var e = Event.current;

        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
        if (e.type == EventType.Repaint)
        {
            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
        }

        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
        {
            display = !display;
            e.Use();
        }

        return display;
    }

    // Helper function to draw property with tooltip
    private void DrawPropertyWithTooltip(MaterialEditor editor, MaterialProperty prop, string tooltip)
    {
        EditorGUILayout.BeginHorizontal();
        editor.ShaderProperty(prop, prop.displayName);
        
        if (GUILayout.Button(new GUIContent("?", tooltip), GUILayout.Width(20)))
        {
            // This just shows the tooltip on hover, clicking doesn't do anything
        }
        
        EditorGUILayout.EndHorizontal();
    }

    // Apply a preset to the material
    private void ApplyPreset(Material material, ShaderPreset preset)
    {
        foreach (var kvp in preset.FloatValues)
        {
            material.SetFloat(kvp.Key, kvp.Value);
        }
        
        foreach (var kvp in preset.ColorValues)
        {
            material.SetColor(kvp.Key, kvp.Value);
        }
        
        foreach (var kvp in preset.VectorValues)
        {
            material.SetVector(kvp.Key, kvp.Value);
        }
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        var material = materialEditor.target as Material;

        // Preset section
        _showPresets = DrawFoldout("Presets", _showPresets);
        if (_showPresets)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Quick Settings", EditorStyles.boldLabel);
            
            EditorGUILayout.Space();
            
            foreach (var preset in _presets)
            {
                if (GUILayout.Button(preset.Name))
                {
                    ApplyPreset(material, preset);
                }
            }
            
            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();
        }

        // Base settings
        _showBaseSettings = DrawFoldout("Base Settings", _showBaseSettings);
        if (_showBaseSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty mainColor = FindProperty("_MainColor", properties);
            MaterialProperty colorVariation = FindProperty("_ColorVariation", properties);
            MaterialProperty brightness = FindProperty("_Brightness", properties);
            MaterialProperty contrast = FindProperty("_Contrast", properties);
            
            DrawPropertyWithTooltip(materialEditor, mainColor, "Base color tint for the kaleidoscope effect");
            DrawPropertyWithTooltip(materialEditor, colorVariation, "Amount of color variation in the effect");
            DrawPropertyWithTooltip(materialEditor, brightness, "Overall brightness of the effect");
            DrawPropertyWithTooltip(materialEditor, contrast, "Contrast/gamma adjustment for the final output");
            
            EditorGUILayout.EndVertical();
        }

        // Rotation settings
        _showRotationSettings = DrawFoldout("Rotation Settings", _showRotationSettings);
        if (_showRotationSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty rotXY = FindProperty("_RotationSpeedXY", properties);
            MaterialProperty rotXZ = FindProperty("_RotationSpeedXZ", properties);
            MaterialProperty rotZY = FindProperty("_RotationSpeedZY", properties);
            
            DrawPropertyWithTooltip(materialEditor, rotXY, "Speed of rotation in the XY plane");
            DrawPropertyWithTooltip(materialEditor, rotXZ, "Speed of rotation in the XZ plane");
            DrawPropertyWithTooltip(materialEditor, rotZY, "Speed of rotation in the ZY plane");
            
            EditorGUILayout.EndVertical();
        }

        // Fractal settings
        _showFractalSettings = DrawFoldout("Fractal Structure", _showFractalSettings);
        if (_showFractalSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty symmetry = FindProperty("_SymmetryCount", properties);
            MaterialProperty symmetryOffset = FindProperty("_SymmetryOffset", properties);
            MaterialProperty fractalIter = FindProperty("_FractalIterations", properties);
            MaterialProperty iterScale = FindProperty("_IterationScale", properties);
            MaterialProperty boxDim = FindProperty("_BoxDimensions", properties);
            MaterialProperty zMod = FindProperty("_ZModFactor", properties);
            
            DrawPropertyWithTooltip(materialEditor, symmetry, "Number of repeated segments in the kaleidoscope");
            DrawPropertyWithTooltip(materialEditor, symmetryOffset, "Offset applied to the symmetry");
            DrawPropertyWithTooltip(materialEditor, fractalIter, "Number of iterations for the fractal calculation");
            DrawPropertyWithTooltip(materialEditor, iterScale, "Scaling factor applied in each iteration");
            DrawPropertyWithTooltip(materialEditor, boxDim, "Dimensions of the base boxes in the fractal");
            DrawPropertyWithTooltip(materialEditor, zMod, "Modulation factor for the Z-axis");
            
            EditorGUILayout.EndVertical();
        }

        // Ray marching settings
        _showRaymarchSettings = DrawFoldout("Ray Marching Settings", _showRaymarchSettings);
        if (_showRaymarchSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty iterations = FindProperty("_Iterations", properties);
            MaterialProperty stepSize = FindProperty("_StepSize", properties);
            MaterialProperty fractalScale = FindProperty("_FractalScale", properties);
            
            DrawPropertyWithTooltip(materialEditor, iterations, "Maximum number of ray marching steps (higher = better quality but slower)");
            DrawPropertyWithTooltip(materialEditor, stepSize, "Size of each step in the ray marching (smaller = better quality but slower)");
            DrawPropertyWithTooltip(materialEditor, fractalScale, "Overall scale of the fractal");
            
            EditorGUILayout.EndVertical();
        }

        // Animation settings
        _showAnimationSettings = DrawFoldout("Animation Settings", _showAnimationSettings);
        if (_showAnimationSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty animSpeed = FindProperty("_AnimationSpeed", properties);
            MaterialProperty fracAnim1 = FindProperty("_FractalAnimSpeed1", properties);
            MaterialProperty fracAnim2 = FindProperty("_FractalAnimSpeed2", properties);
            MaterialProperty fracAnim3 = FindProperty("_FractalAnimSpeed3", properties);
            MaterialProperty wave1 = FindProperty("_WaveScale1", properties);
            MaterialProperty wave2 = FindProperty("_WaveScale2", properties);
            
            DrawPropertyWithTooltip(materialEditor, animSpeed, "Overall animation speed multiplier");
            DrawPropertyWithTooltip(materialEditor, fracAnim1, "Animation speed for the fractal's internal scale");
            DrawPropertyWithTooltip(materialEditor, fracAnim2, "Animation speed for the first wave effect");
            DrawPropertyWithTooltip(materialEditor, fracAnim3, "Animation speed for the second wave effect");
            DrawPropertyWithTooltip(materialEditor, wave1, "Scale of the first wave effect");
            DrawPropertyWithTooltip(materialEditor, wave2, "Scale of the second wave effect");
            
            EditorGUILayout.EndVertical();
        }

        // AudioLink settings
        _showAudioLinkSettings = DrawFoldout("AudioLink Settings", _showAudioLinkSettings);
        if (_showAudioLinkSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty useAudioLink = FindProperty("_UseAudioLink", properties);
            MaterialProperty bassIntensity = FindProperty("_AudioLinkBassIntensity", properties);
            MaterialProperty midIntensity = FindProperty("_AudioLinkMidIntensity", properties);
            MaterialProperty highIntensity = FindProperty("_AudioLinkHighIntensity", properties);
            MaterialProperty beatMult = FindProperty("_AudioLinkBeatMultiplier", properties);
            MaterialProperty bassEffect = FindProperty("_BassEffect", properties);
            MaterialProperty midEffect = FindProperty("_MidEffect", properties);
            MaterialProperty highEffect = FindProperty("_HighEffect", properties);
            
            DrawPropertyWithTooltip(materialEditor, useAudioLink, "Enable/disable AudioLink reactivity");
            
            EditorGUI.BeginDisabledGroup(material.GetFloat("_UseAudioLink") < 0.5f);
            
            DrawPropertyWithTooltip(materialEditor, bassIntensity, "Intensity of the bass frequency response");
            DrawPropertyWithTooltip(materialEditor, midIntensity, "Intensity of the mid frequency response");
            DrawPropertyWithTooltip(materialEditor, highIntensity, "Intensity of the high frequency response");
            DrawPropertyWithTooltip(materialEditor, beatMult, "Multiplier for beat detection response");
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Effect Mapping", EditorStyles.boldLabel);
            
            DrawPropertyWithTooltip(materialEditor, bassEffect, "What parameter should bass frequencies affect");
            DrawPropertyWithTooltip(materialEditor, midEffect, "What parameter should mid frequencies affect");
            DrawPropertyWithTooltip(materialEditor, highEffect, "What parameter should high frequencies affect");
            
            EditorGUI.EndDisabledGroup();
            
            EditorGUILayout.EndVertical();
        }

        // Color settings
        _showColorSettings = DrawFoldout("Color Settings", _showColorSettings);
        if (_showColorSettings)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            MaterialProperty colorCycle = FindProperty("_ColorCycleSpeed", properties);
            MaterialProperty pulseIntensity = FindProperty("_PulseIntensity", properties);
            MaterialProperty colorBlend = FindProperty("_ColorBlendAmount", properties);
            
            DrawPropertyWithTooltip(materialEditor, colorCycle, "Speed of the color cycling effect");
            DrawPropertyWithTooltip(materialEditor, pulseIntensity, "Intensity of the pulsing effect");
            DrawPropertyWithTooltip(materialEditor, colorBlend, "Amount of color blending");
            
            EditorGUILayout.EndVertical();
        }

        // Bottom section with additional notes
        EditorGUILayout.Space();
        EditorGUILayout.HelpBox("This shader implements an audio-reactive kaleidoscopic fractal effect. It works best when placed on a quad or used as a skybox. For optimal performance, reduce Ray March Iterations or increase Step Size if experiencing low framerates.", MessageType.Info);
    }
} 