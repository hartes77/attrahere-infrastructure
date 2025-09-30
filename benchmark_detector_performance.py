#!/usr/bin/env python3
"""
Detector Performance Benchmarking Tool

Measures performance of ML pattern detectors to identify bottlenecks
and establish SLA baselines for production deployment.
"""

import time
import sys
import ast
import statistics
from typing import Dict, List, Any
from pathlib import Path

sys.path.insert(0, 'attrahere-platform')

def generate_test_code_samples() -> Dict[str, str]:
    """Generate different types of test code for benchmarking"""
    
    samples = {
        "simple_ml": """
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

df = pd.read_csv("data.csv")
X = df.drop("target", axis=1)
y = df["target"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
model = RandomForestClassifier()
model.fit(X_train, y_train)
score = model.score(X_test, y_test)
""",
        
        "complex_preprocessing": """
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# Data loading
df = pd.read_csv("large_dataset.csv")
X = df.drop("target", axis=1)
y = df["target"]

# Complex preprocessing pipeline
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Potential leakage!

encoder = LabelEncoder()
y_encoded = encoder.fit_transform(y)

# Feature engineering
X_scaled_df = pd.DataFrame(X_scaled)
X_scaled_df['feature_interaction'] = X_scaled_df[0] * X_scaled_df[1]
X_scaled_df['feature_squared'] = X_scaled_df[0] ** 2

# Split after preprocessing (problematic)
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled_df, y_encoded, test_size=0.2, random_state=42
)

# Model training
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluation
train_score = accuracy_score(y_train, model.predict(X_train))
test_score = accuracy_score(y_test, model.predict(X_test))

# Cross-validation
cv_scores = cross_val_score(model, X_train, y_train, cv=5)
""",
        
        "gpu_intensive": """
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import numpy as np

class MLPModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.layers = nn.Sequential(
            nn.Linear(784, 512),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, 10)
        )
    
    def forward(self, x):
        return self.layers(x)

# Training loop with potential memory issues
model = MLPModel()
optimizer = optim.Adam(model.parameters(), lr=0.001)
criterion = nn.CrossEntropyLoss()

losses = []
for epoch in range(100):
    for batch_idx, (data, target) in enumerate(dataloader):
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
        
        # Potential memory leak - accumulating tensors
        losses.append(loss)  # No .detach()!
        
        if batch_idx % 100 == 0:
            print(f'Epoch: {epoch}, Loss: {loss.item()}')
""",
        
        "time_series": """
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor

# Generate time series data
dates = pd.date_range('2020-01-01', periods=1000, freq='D')
values = np.random.randn(1000).cumsum()
df = pd.DataFrame({'date': dates, 'value': values})

# Feature engineering with potential temporal leakage
df['lag_1'] = df['value'].shift(1)
df['lag_7'] = df['value'].shift(7)
df['future_value'] = df['value'].shift(-1)  # Future leakage!
df['rolling_mean'] = df['value'].rolling(30).mean()

# Target variable
df['target'] = (df['value'] > df['value'].shift(1)).astype(int)

# Random split (problematic for time series)
X = df[['lag_1', 'lag_7', 'future_value', 'rolling_mean']].dropna()
y = df['target'].iloc[30:-1]  # Align with dropna

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42  # Should be temporal!
)

model = RandomForestRegressor()
model.fit(X_train, y_train)
score = model.score(X_test, y_test)
""",
        
        "large_file": """
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Inefficient data loading patterns
df1 = pd.read_csv("huge_dataset_1.csv")  # No chunking
df2 = pd.read_csv("huge_dataset_2.csv")  # No dtype specification
df3 = pd.read_csv("huge_dataset_3.csv")  # Loading all columns

# Multiple inefficient operations
for i in range(len(df1)):  # Inefficient iteration
    value = df1.iloc[i]['column']
    # Process row by row instead of vectorized

# Memory-intensive operations
df_combined = pd.concat([df1, df2, df3])  # Large memory usage
df_combined = df_combined.drop_duplicates()  # After large concat

# Magic numbers everywhere
threshold_1 = 0.7832947  # Magic threshold
threshold_2 = 0.9234756  # Another magic number
learning_rate = 0.00734829  # Magic learning rate

X = df_combined.drop("target", axis=1)
y = df_combined["target"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

model = RandomForestClassifier(
    n_estimators=147,  # Magic number
    max_depth=23,      # Magic number
    min_samples_split=17  # Magic number
)
model.fit(X_train, y_train)
"""
    }
    
    return samples

def benchmark_detector_performance():
    """Benchmark detector performance on various code samples"""
    
    try:
        # Import detectors
        from analysis_core.ml_analyzer.detectors.test_contamination_detector import TestSetContaminationDetector
        from analysis_core.ml_analyzer.ast_engine import ASTAnalysisResult
        
        print("🚀 Starting Detector Performance Benchmarking")
        print("=" * 60)
        
        # Initialize detector
        detector = TestSetContaminationDetector()
        
        # Get test samples
        samples = generate_test_code_samples()
        
        # Benchmark results
        results = {}
        
        for sample_name, code in samples.items():
            print(f"\n📊 Benchmarking: {sample_name}")
            print("-" * 40)
            
            # Parse code
            try:
                tree = ast.parse(code)
            except SyntaxError as e:
                print(f"❌ Syntax error in {sample_name}: {e}")
                continue
            
            # Create analysis object
            analysis = ASTAnalysisResult(
                file_path=f"benchmark_{sample_name}.py",
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
            
            # Benchmark multiple runs
            times = []
            patterns_found = []
            
            for run in range(5):  # 5 runs for average
                start_time = time.perf_counter()
                
                patterns = detector.detect_patterns(analysis)
                
                end_time = time.perf_counter()
                execution_time = end_time - start_time
                
                times.append(execution_time)
                patterns_found.append(len(patterns))
            
            # Calculate statistics
            avg_time = statistics.mean(times)
            min_time = min(times)
            max_time = max(times)
            std_time = statistics.stdev(times) if len(times) > 1 else 0
            avg_patterns = statistics.mean(patterns_found)
            
            results[sample_name] = {
                'avg_time': avg_time,
                'min_time': min_time,
                'max_time': max_time,
                'std_time': std_time,
                'avg_patterns': avg_patterns,
                'code_lines': len(code.splitlines()),
                'code_size_chars': len(code)
            }
            
            print(f"  ⏱️  Average time: {avg_time*1000:.2f}ms")
            print(f"  ⚡ Min time: {min_time*1000:.2f}ms")
            print(f"  🐌 Max time: {max_time*1000:.2f}ms")
            print(f"  📊 Std deviation: {std_time*1000:.2f}ms")
            print(f"  🔍 Patterns found: {avg_patterns:.1f}")
            print(f"  📝 Code lines: {results[sample_name]['code_lines']}")
            print(f"  💾 Code size: {results[sample_name]['code_size_chars']} chars")
        
        # Summary analysis
        print(f"\n🎯 PERFORMANCE SUMMARY")
        print("=" * 60)
        
        total_avg_time = sum(r['avg_time'] for r in results.values())
        total_patterns = sum(r['avg_patterns'] for r in results.values())
        total_lines = sum(r['code_lines'] for r in results.values())
        
        print(f"📊 Total samples tested: {len(results)}")
        print(f"⏱️  Total average time: {total_avg_time*1000:.2f}ms")
        print(f"🔍 Total patterns found: {total_patterns:.0f}")
        print(f"📝 Total lines analyzed: {total_lines}")
        print(f"⚡ Average time per line: {(total_avg_time/total_lines)*1000:.2f}ms/line")
        print(f"🎯 Average patterns per sample: {total_patterns/len(results):.1f}")
        
        # Performance analysis
        print(f"\n📈 PERFORMANCE ANALYSIS")
        print("-" * 40)
        
        slowest = max(results.items(), key=lambda x: x[1]['avg_time'])
        fastest = min(results.items(), key=lambda x: x[1]['avg_time'])
        most_patterns = max(results.items(), key=lambda x: x[1]['avg_patterns'])
        
        print(f"🐌 Slowest sample: {slowest[0]} ({slowest[1]['avg_time']*1000:.2f}ms)")
        print(f"⚡ Fastest sample: {fastest[0]} ({fastest[1]['avg_time']*1000:.2f}ms)")
        print(f"🔍 Most patterns: {most_patterns[0]} ({most_patterns[1]['avg_patterns']:.0f} patterns)")
        
        # Performance targets
        print(f"\n🎯 PRODUCTION READINESS ASSESSMENT")
        print("-" * 40)
        
        target_time_per_line = 1.0  # 1ms per line target
        actual_time_per_line = (total_avg_time/total_lines)*1000
        
        if actual_time_per_line <= target_time_per_line:
            print(f"✅ Performance TARGET MET: {actual_time_per_line:.2f}ms/line <= {target_time_per_line}ms/line")
        else:
            print(f"⚠️  Performance TARGET MISSED: {actual_time_per_line:.2f}ms/line > {target_time_per_line}ms/line")
        
        # SLA recommendations
        if total_avg_time <= 0.1:  # 100ms total
            sla_tier = "Premium (< 100ms)"
        elif total_avg_time <= 0.5:  # 500ms total
            sla_tier = "Standard (< 500ms)"
        else:
            sla_tier = "Basic (> 500ms)"
        
        print(f"📋 Recommended SLA Tier: {sla_tier}")
        
        return results
        
    except Exception as e:
        print(f"❌ Benchmarking failed: {e}")
        import traceback
        traceback.print_exc()
        return {}

if __name__ == "__main__":
    results = benchmark_detector_performance()
    
    if results:
        print(f"\n✅ Benchmarking completed successfully!")
        print(f"🎯 Results available for {len(results)} test samples")
    else:
        print(f"\n❌ Benchmarking failed!")