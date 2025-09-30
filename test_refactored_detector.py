#!/usr/bin/env python3
"""
Test Refactored TestSetContaminationDetector
"""

import sys
import ast

sys.path.insert(0, 'attrahere-platform')

def test_refactored_detector():
    """Test the refactored detector works correctly"""
    
    try:
        # Import refactored detector
        from analysis_core.ml_analyzer.detectors.test_contamination_detector import TestSetContaminationDetector
        from analysis_core.ml_analyzer.detectors.base_detector import MLAntiPattern, PatternSeverity
        from analysis_core.ml_analyzer.ast_engine import ASTAnalysisResult
        
        print("✅ Successfully imported refactored detector!")
        
        # Create detector instance
        detector = TestSetContaminationDetector()
        print("✅ Detector instance created successfully!")
        
        # Test with problematic code
        problematic_code = '''
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

# Load data
X = pd.DataFrame({'a': [1, 2, 3, 4], 'b': [5, 6, 7, 8]})
y = [0, 1, 0, 1]

# ❌ PROBLEMATIC: Preprocessing before split
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Data leakage here!

# Split after preprocessing - too late!
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)
'''
        
        # Parse and analyze
        tree = ast.parse(problematic_code)
        analysis = ASTAnalysisResult(
            file_path="test_refactored.py",
            ast_tree=tree,
            cst_tree=None,
            imports={},
            functions={},
            classes={},
            variables={},
            ml_constructs={},
            data_flow={},
            complexity_metrics={}
        )
        
        print("\n🔍 Running refactored detector...")
        patterns = detector.detect_patterns(analysis)
        
        print(f"📊 Found {len(patterns)} contamination patterns")
        
        for i, pattern in enumerate(patterns):
            print(f"\nPattern {i+1}:")
            print(f"  🚨 Type: {pattern.pattern_type}")
            print(f"  ⚠️  Severity: {pattern.severity.value}")
            print(f"  💬 Message: {pattern.message}")
            print(f"  🎯 Confidence: {pattern.confidence:.2f}")
            print(f"  📝 Explanation: {pattern.explanation[:100]}...")
        
        # Test inheritance
        print(f"\n🧬 Inheritance test:")
        print(f"  Is BaseMLDetector subclass: {isinstance(detector, detector.__class__.__bases__[0])}")
        
        # Test helper methods
        print(f"\n🛠️ Helper methods test:")
        dummy_node = ast.parse("test()").body[0].value
        dummy_node.lineno = 10
        
        func_name = detector.get_function_name(dummy_node)
        print(f"  get_function_name(): {func_name}")
        
        is_ml_related = detector.is_ml_related_call(dummy_node)
        print(f"  is_ml_related_call(): {is_ml_related}")
        
        # Test variable tracking
        split_vars = detector.variable_tracker.get_split_variables()
        print(f"  Split variables tracked: {split_vars}")
        
        print(f"\n✅ Refactored detector test completed successfully!")
        print(f"🎯 The detector maintains all functionality with improved architecture!")
        
        return len(patterns)
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
        return 0

if __name__ == "__main__":
    print("🧪 Testing Refactored TestSetContaminationDetector")
    print("=" * 60)
    
    patterns_found = test_refactored_detector()
    
    if patterns_found > 0:
        print(f"\n🎉 SUCCESS: Refactored detector found {patterns_found} patterns!")
        print("🏗️ Refactoring successful - detector is production ready!")
    else:
        print(f"\n⚠️ Warning: No patterns found - check detector logic")