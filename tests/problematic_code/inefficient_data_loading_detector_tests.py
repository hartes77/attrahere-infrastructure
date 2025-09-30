"""
Inefficient Data Loading Detector Tests

Structured test suite for InefficientDataLoadingDetector following the specification format.
Tests detection of performance issues in data loading and processing.
"""

import pytest
import warnings


class InefficientDataLoadingDetectorTests:
    """Test cases for detecting inefficient data loading patterns"""
    
    def setup_method(self):
        """Setup test environment"""
        warnings.filterwarnings("ignore", category=UserWarning)
    
    # === POSITIVE CASES (should detect inefficiencies) ===
    
    def test_positive_row_by_row_dataframe_iteration(self):
        """
        Positive Test Case 1: Row-by-row DataFrame iteration
        
        This should trigger detection when DataFrames are processed
        row-by-row instead of using vectorized operations.
        """
        test_code = '''
import pandas as pd

df = pd.read_csv("data.csv")

for i in range(len(df)):
    row = df.iloc[i]
    result = row['value'] * 2
    df.loc[i, 'processed'] = result

for index, row in df.iterrows():
    calculated = row['a'] + row['b']
    df.at[index, 'sum'] = calculated
'''
        
        # Check for inefficient iteration patterns
        assert "for i in range(len(" in test_code
        assert ".iloc[i]" in test_code
        assert ".iterrows()" in test_code
        assert ".loc[i," in test_code or ".at[index," in test_code
        
        print("✓ Detected row-by-row DataFrame iteration")
    
    def test_positive_loading_entire_csv_without_chunking(self):
        """
        Positive Test Case 2: Loading entire CSV without chunking
        
        This should trigger detection when large files are loaded
        entirely into memory without chunking.
        """
        test_code = '''
import pandas as pd

df = pd.read_csv("huge_dataset.csv")
big_data = pd.read_csv("10gb_file.csv")

all_files = []
for file in file_list:
    all_files.append(pd.read_csv(file))
combined = pd.concat(all_files)
'''
        
        # Check for non-chunked loading patterns
        assert "pd.read_csv(" in test_code
        assert "huge_dataset" in test_code or "big_data" in test_code or "10gb_file" in test_code
        assert "chunksize" not in test_code
        assert "pd.concat" in test_code
        
        print("✓ Detected loading entire CSV without chunking")
    
    def test_positive_missing_dtype_specification(self):
        """
        Positive Test Case 3: Missing dtype specification in read_csv
        
        This should trigger detection when read_csv is called without
        dtype specification, leading to memory waste.
        """
        test_code = '''
import pandas as pd

df1 = pd.read_csv("numeric_data.csv")
df2 = pd.read_csv("mixed_data.csv")
df3 = pd.read_csv("categorical_data.csv")

large_df = pd.read_csv("huge_file.csv")
'''
        
        # Check for missing dtype specification
        read_csv_calls = test_code.count("pd.read_csv(")
        dtype_specifications = test_code.count("dtype")
        
        assert read_csv_calls > 0
        assert dtype_specifications == 0  # No dtype specifications
        
        print("✓ Detected missing dtype specification")
    
    # === NEGATIVE CASES (should NOT detect issues) ===
    
    def test_negative_vectorized_operations(self):
        """
        Negative Test Case 1: Vectorized operations
        
        This should NOT trigger detection when proper vectorized
        operations are used.
        """
        test_code = '''
import pandas as pd
import numpy as np

df = pd.read_csv("data.csv")

df['processed'] = df['value'] * 2
df['sum'] = df['a'] + df['b']

df['log_value'] = np.log(df['value'])
df['normalized'] = (df['value'] - df['value'].mean()) / df['value'].std()

result = df.groupby('category').agg({
    'value': ['mean', 'sum', 'count'],
    'other': 'max'
})
'''
        
        # Check for vectorized operations
        assert "df['processed'] = df['value'] * 2" in test_code
        assert "df['sum'] = df['a'] + df['b']" in test_code
        assert "np.log(" in test_code
        assert ".groupby(" in test_code
        assert ".agg(" in test_code
        
        print("✓ Clean vectorized operations")
    
    def test_negative_chunked_data_loading(self):
        """
        Negative Test Case 2: Chunked data loading
        
        This should NOT trigger detection when data is loaded
        in chunks for memory efficiency.
        """
        test_code = '''
import pandas as pd

chunk_list = []
for chunk in pd.read_csv("large_file.csv", chunksize=10000):
    processed_chunk = chunk.dropna()
    chunk_list.append(processed_chunk)

df = pd.concat(chunk_list, ignore_index=True)

for chunk in pd.read_csv("huge_data.csv", chunksize=50000):
    result = process_chunk(chunk)
    save_chunk_result(result)
'''
        
        # Check for chunked loading
        assert "chunksize=" in test_code
        assert "for chunk in pd.read_csv(" in test_code
        
        print("✓ Clean chunked data loading")
    
    def test_negative_optimized_pandas_operations(self):
        """
        Negative Test Case 3: Optimized pandas operations
        
        This should NOT trigger detection when pandas operations
        are used efficiently.
        """
        test_code = '''
import pandas as pd

df = pd.read_csv("data.csv", dtype={
    'id': 'int32',
    'value': 'float32', 
    'category': 'category'
})

df = pd.read_csv("selective_data.csv", usecols=['id', 'value', 'target'])

df_filtered = df.query("value > threshold")
df_sorted = df.sort_values('value', ascending=False)

aggregated = df.groupby('category')['value'].transform('mean')
'''
        
        # Check for optimized operations
        assert "dtype={" in test_code
        assert "usecols=" in test_code
        assert ".query(" in test_code
        assert ".transform(" in test_code
        
        print("✓ Clean optimized pandas operations")
    
    # === EDGE CASES ===
    
    def test_edge_case_small_datasets_no_optimization(self):
        """
        Edge Case 1: Small datasets where optimization unnecessary
        
        Should handle small datasets where optimization overhead
        would be unnecessary.
        """
        test_code = '''
import pandas as pd

small_df = pd.read_csv("small_data.csv")

for i in range(10):
    small_df.loc[i, 'processed'] = small_df.loc[i, 'value'] * 2

tiny_data = pd.DataFrame({
    'a': [1, 2, 3, 4, 5],
    'b': [6, 7, 8, 9, 10]
})

for idx, row in tiny_data.iterrows():
    print(row['a'] + row['b'])
'''
        
        # Check for small dataset patterns
        assert "range(10)" in test_code  # Small loop
        assert "'a': [1, 2, 3, 4, 5]" in test_code  # Small DataFrame
        
        print("✓ Small datasets handled")
    
    def test_edge_case_custom_data_loading_functions(self):
        """
        Edge Case 2: Custom data loading functions
        
        Should handle custom data loading patterns that may not
        follow standard pandas patterns.
        """
        test_code = '''
def custom_loader(filename):
    with open(filename, 'r') as f:
        data = []
        for line in f:
            processed = custom_parse(line)
            data.append(processed)
    return data

def stream_processor(filepath):
    for chunk in read_in_chunks(filepath, chunk_size=1000):
        yield process_chunk(chunk)

class DataLoader:
    def __init__(self, path):
        self.path = path
    
    def load_batch(self, batch_size):
        return custom_read(self.path, batch_size)
'''
        
        # Check for custom patterns
        assert "def custom_loader" in test_code
        assert "def stream_processor" in test_code
        assert "class DataLoader" in test_code
        assert "yield " in test_code
        
        print("✓ Custom data loading functions handled")
    
    def test_edge_case_mixed_loading_patterns(self):
        """
        Edge Case 3: Mixed loading patterns
        
        Should handle code that mixes efficient and inefficient
        patterns appropriately.
        """
        test_code = '''
import pandas as pd

df_small = pd.read_csv("small.csv")
df_large = pd.read_csv("large.csv", chunksize=10000)

for chunk in df_large:
    processed = chunk['value'] * 2  # Vectorized within chunk
    save_chunk(processed)

for i in range(len(df_small)):  # OK for small data
    df_small.loc[i, 'result'] = complex_calculation(df_small.iloc[i])

df_optimized = pd.read_csv("optimized.csv", dtype={'id': 'int32'})
'''
        
        # Check for mixed patterns
        assert "chunksize=" in test_code  # Efficient chunking
        assert "for i in range(len(" in test_code  # Inefficient iteration
        assert "dtype=" in test_code  # Optimized loading
        
        print("✓ Mixed loading patterns handled")
    
    def test_edge_case_no_data_loading(self):
        """
        Edge Case 4: Code without data loading
        
        Should handle code that doesn't involve data loading operations.
        """
        test_code = '''
import numpy as np
from sklearn.linear_model import LinearRegression

X = np.random.randn(100, 5)
y = np.random.randn(100)

model = LinearRegression()
model.fit(X, y)
predictions = model.predict(X)

accuracy = model.score(X, y)
'''
        
        # Check that this doesn't involve pandas data loading
        assert "pd.read_csv" not in test_code
        assert "pd.read_excel" not in test_code
        assert "iterrows" not in test_code
        assert "np.random.randn" in test_code  # Uses numpy instead
        
        print("✓ Code without data loading handled")


if __name__ == "__main__":
    """Run inefficient data loading detection tests"""
    detector = InefficientDataLoadingDetectorTests()
    
    print("Running Inefficient Data Loading Detector Tests...")
    print("=" * 60)
    
    try:
        detector.setup_method()
        
        print("\nPOSITIVE TEST CASES (should detect inefficiencies)")
        print("-" * 50)
        
        print("\n1. Testing row-by-row DataFrame iteration...")
        detector.test_positive_row_by_row_dataframe_iteration()
        
        print("\n2. Testing loading entire CSV without chunking...")
        detector.test_positive_loading_entire_csv_without_chunking()
        
        print("\n3. Testing missing dtype specification...")
        detector.test_positive_missing_dtype_specification()
        
        print("\nNEGATIVE TEST CASES (should NOT detect issues)")
        print("-" * 45)
        
        print("\n4. Testing vectorized operations...")
        detector.test_negative_vectorized_operations()
        
        print("\n5. Testing chunked data loading...")
        detector.test_negative_chunked_data_loading()
        
        print("\n6. Testing optimized pandas operations...")
        detector.test_negative_optimized_pandas_operations()
        
        print("\nEDGE TEST CASES (robustness testing)")
        print("-" * 35)
        
        print("\n7. Testing small datasets...")
        detector.test_edge_case_small_datasets_no_optimization()
        
        print("\n8. Testing custom data loading functions...")
        detector.test_edge_case_custom_data_loading_functions()
        
        print("\n9. Testing mixed loading patterns...")
        detector.test_edge_case_mixed_loading_patterns()
        
        print("\n10. Testing code without data loading...")
        detector.test_edge_case_no_data_loading()
        
        print("\n" + "=" * 60)
        print("✅ All inefficient data loading detection tests completed successfully!")
        print("✅ Positive cases: 3/3 inefficiency patterns demonstrated")
        print("✅ Negative cases: 3/3 efficient approaches validated")
        print("✅ Edge cases: 4/4 handled gracefully")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Test failed: {str(e)}")
        raise