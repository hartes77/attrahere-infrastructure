#!/usr/bin/env python3
"""
Sprint 3 TestSetContaminationDetector Test
"""

import sys
import os
import ast
from pathlib import Path

# Add current directory to path for imports
sys.path.insert(0, '.')

try:
    from analysis_core.ml_analyzer.ast_engine import MLSemanticAnalyzer, ASTAnalysisResult
    from analysis_core.ml_analyzer.ml_patterns import TestSetContaminationDetector, MLAntiPattern
    
    print("✅ Successfully imported TestSetContaminationDetector!")
    
    # Create a test detector
    detector = TestSetContaminationDetector()
    print("✅ TestSetContaminationDetector initialized successfully!")
    
    # Test on our actual contamination test file
    test_code = '''
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Generate test data
X = np.random.randn(1000, 10)
y = (X[:, 0] + X[:, 1] > 0).astype(int)

# Split data normally
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Test for exact duplicates - this should trigger detection
train_samples = set(tuple(row) for row in X_train)
test_samples = set(tuple(row) for row in X_test) 
duplicates = train_samples.intersection(test_samples)
print(f"Found {len(duplicates)} duplicates")
'''
    
    # Parse the test code
    tree = ast.parse(test_code)
    
    # Create mock analysis result with correct structure
    analysis = ASTAnalysisResult(
        file_path="test_contamination.py",
        ast_tree=tree,
        cst_tree=None,  # Mock CST tree
        imports={},
        functions={},
        classes={},
        variables={},
        ml_constructs={},
        data_flow={},
        complexity_metrics={}
    )
    
    print("\n🔍 Testing contamination detection...")
    
    # Run detection
    patterns = detector.detect_patterns(analysis)
    
    print(f"✅ Detection completed! Found {len(patterns)} patterns")
    
    for i, pattern in enumerate(patterns):
        print(f"\nPattern {i+1}:")
        print(f"  Type: {pattern.pattern_type}")
        print(f"  Severity: {pattern.severity.value}")
        print(f"  Message: {pattern.message}")
        print(f"  Confidence: {pattern.confidence}")
    
    # Test variable tracking
    print(f"\n🔍 Variable tracking test:")
    split_vars = detector.variable_tracker.get_split_variables()
    print(f"  Split variables detected: {split_vars}")
    
    operations = detector.variable_tracker.get_chronological_operations()
    print(f"  Operations tracked: {len(operations)}")
    
    print("\n🎯 Sprint 3 detector tests completed successfully!")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("📁 Current directory:", os.getcwd())
    
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    print(f"   Error type: {type(e).__name__}")
    import traceback
    traceback.print_exc()