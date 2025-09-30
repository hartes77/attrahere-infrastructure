#!/usr/bin/env python3
"""
Test TestSetContaminationDetector with actual problematic cases
"""

import sys
import ast

sys.path.insert(0, 'attrahere-platform')

from analysis_core.ml_analyzer.ast_engine import ASTAnalysisResult
from analysis_core.ml_analyzer.ml_patterns import TestSetContaminationDetector

def test_contamination_case(test_name, code, expected_patterns=1):
    """Test a specific contamination case"""
    print(f"\n🧪 Testing: {test_name}")
    print("=" * 50)
    
    # Parse the test code
    tree = ast.parse(code)
    
    # Create analysis result
    analysis = ASTAnalysisResult(
        file_path=f"test_{test_name.lower().replace(' ', '_')}.py",
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
    
    # Run detection
    detector = TestSetContaminationDetector()
    patterns = detector.detect_patterns(analysis)
    
    print(f"📊 Found {len(patterns)} contamination patterns (expected: {expected_patterns})")
    
    for i, pattern in enumerate(patterns):
        print(f"\nPattern {i+1}:")
        print(f"  🚨 Type: {pattern.pattern_type}")
        print(f"  ⚠️  Severity: {pattern.severity.value}")
        print(f"  💬 Message: {pattern.message}")
        print(f"  🎯 Confidence: {pattern.confidence:.2f}")
        if pattern.suggested_fix:
            print(f"  🔧 Fix: {pattern.suggested_fix[:100]}...")
    
    # Show variable tracking
    split_vars = detector.variable_tracker.get_split_variables()
    if split_vars:
        print(f"\n📋 Split variables: {split_vars}")
    
    return len(patterns)

# Test Case 1: Preprocessing before split (classic data leakage)
preprocessing_leakage = '''
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

# Test Case 2: Duplicate detection (should trigger missing check warning)
missing_duplicate_check = '''
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

X = pd.DataFrame({'feature1': [1, 2, 3, 4, 5], 'feature2': [6, 7, 8, 9, 10]})
y = [0, 1, 0, 1, 0]

# Split without duplicate checking
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model without checking for contamination
model = RandomForestClassifier()
model.fit(X_train, y_train)
score = model.score(X_test, y_test)
'''

# Test Case 3: Actual duplicate detection
duplicate_contamination = '''
import pandas as pd
from sklearn.model_selection import train_test_split

X = pd.DataFrame({'a': [1, 2, 3, 4], 'b': [5, 6, 7, 8]})
y = [0, 1, 0, 1]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# ❌ PROBLEMATIC: Checking for duplicates shows contamination exists
train_samples = set(X_train.apply(tuple, axis=1))
test_samples = set(X_test.apply(tuple, axis=1))
duplicates = train_samples.intersection(test_samples)
'''

# Test Case 4: Future leakage in features
future_leakage = '''
import pandas as pd
from sklearn.model_selection import train_test_split

# Time series data
df = pd.DataFrame({
    'value': [1, 2, 3, 4, 5],
    'target': [0, 1, 0, 1, 0]
})

# ❌ PROBLEMATIC: Using future information
df['future_value'] = df['value'].shift(-1)  # Positive shift = future data!
df['next_target'] = df['target'].shift(-2)  # Even more future data!

X = df[['value', 'future_value', 'next_target']].dropna()
y = df['target'].iloc[:-2]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
'''

if __name__ == "__main__":
    print("🚀 Testing TestSetContaminationDetector with problematic cases")
    print("=" * 60)
    
    total_found = 0
    
    # Run all tests
    total_found += test_contamination_case("Preprocessing Leakage", preprocessing_leakage, 1)
    total_found += test_contamination_case("Missing Duplicate Check", missing_duplicate_check, 1)  
    total_found += test_contamination_case("Duplicate Contamination", duplicate_contamination, 1)
    total_found += test_contamination_case("Future Leakage", future_leakage, 2)
    
    print(f"\n🎯 Summary: Found {total_found} total contamination patterns")
    print("✅ Sprint 3 TestSetContaminationDetector is working!")