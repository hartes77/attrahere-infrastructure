#!/usr/bin/env python3
"""
Quick test script for the TestSetContaminationDetector
"""

import sys
import os

# Add the platform directory to path
sys.path.insert(0, 'attrahere-platform')

try:
    from analysis_core.ml_analyzer.ast_engine import MLSemanticAnalyzer, ASTAnalysisResult
    from analysis_core.ml_analyzer.ml_patterns import TestSetContaminationDetector, MLAntiPattern
    
    print("✅ Successfully imported TestSetContaminationDetector!")
    
    # Create a test detector
    detector = TestSetContaminationDetector()
    print("✅ TestSetContaminationDetector initialized successfully!")
    
    # Test basic functionality
    print(f"✅ Split functions: {len(detector.split_functions)}")
    print(f"✅ Preprocessing classes: {len(detector.preprocessing_classes)}")
    print(f"✅ Variable tracker initialized: {detector.variable_tracker is not None}")
    
    # Test the variable tracker
    detector.variable_tracker.reset()
    print("✅ Variable tracker reset successful!")
    
    print("\n🎯 TestSetContaminationDetector is ready for Sprint 3!")
    print("🚀 All core components successfully imported and initialized!")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("📁 Current directory:", os.getcwd())
    print("📂 Available directories:")
    for item in os.listdir('.'):
        if os.path.isdir(item):
            print(f"   - {item}/")
    
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    print(f"   Error type: {type(e).__name__}")