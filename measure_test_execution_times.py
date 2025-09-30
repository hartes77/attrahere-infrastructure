#!/usr/bin/env python3
"""
Test Execution Time Measurement

Measures execution times for all detector test suites to validate
performance requirements specified in TEST_SUITE_SPECIFICATION.md
"""

import time
import sys
import subprocess
from pathlib import Path


def measure_test_suite_time(test_file: str, description: str) -> dict:
    """Measure execution time for a test suite"""
    print(f"\n📊 Measuring: {description}")
    print(f"   File: {test_file}")
    
    start_time = time.perf_counter()
    
    try:
        # Run test suite and capture output
        result = subprocess.run(
            [sys.executable, test_file],
            capture_output=True,
            text=True,
            timeout=60  # 60 second timeout
        )
        
        end_time = time.perf_counter()
        execution_time = end_time - start_time
        
        success = result.returncode == 0
        
        if success:
            print(f"   ✅ Completed in {execution_time*1000:.2f}ms")
        else:
            print(f"   ❌ Failed after {execution_time*1000:.2f}ms")
            print(f"   Error: {result.stderr}")
        
        return {
            'test_file': test_file,
            'description': description,
            'execution_time_ms': execution_time * 1000,
            'success': success,
            'stdout': result.stdout if success else None,
            'stderr': result.stderr if not success else None
        }
        
    except subprocess.TimeoutExpired:
        end_time = time.perf_counter()
        execution_time = end_time - start_time
        print(f"   ⏰ Timeout after {execution_time*1000:.2f}ms")
        
        return {
            'test_file': test_file,
            'description': description,
            'execution_time_ms': execution_time * 1000,
            'success': False,
            'error': 'Timeout'
        }
    
    except Exception as e:
        end_time = time.perf_counter()
        execution_time = end_time - start_time
        print(f"   💥 Exception after {execution_time*1000:.2f}ms: {e}")
        
        return {
            'test_file': test_file,
            'description': description,
            'execution_time_ms': execution_time * 1000,
            'success': False,
            'error': str(e)
        }


def main():
    """Main execution time measurement"""
    print("🚀 Test Suite Execution Time Measurement")
    print("=" * 60)
    
    # Define test suites with their target times from specification
    test_suites = [
        {
            'file': 'tests/problematic_code/test_set_contamination.py',
            'description': 'TestSetContaminationDetector',
            'target_time_ms': 50,
            'test_count': 15  # 5 positive + 4 negative + 6 edge
        },
        {
            'file': 'tests/problematic_code/data_leakage_detector_tests.py', 
            'description': 'DataLeakageDetector',
            'target_time_ms': 20,
            'test_count': 8  # 3 positive + 2 negative + 3 edge
        },
        {
            'file': 'tests/problematic_code/gpu_memory_leak_detector_tests.py',
            'description': 'GPUMemoryLeakDetector', 
            'target_time_ms': 30,
            'test_count': 10  # 3 positive + 3 negative + 4 edge
        },
        {
            'file': 'tests/problematic_code/hardcoded_thresholds_detector_tests.py',
            'description': 'HardcodedThresholdsDetector',
            'target_time_ms': 15,
            'test_count': 10  # 3 positive + 3 negative + 4 edge
        },
        {
            'file': 'tests/problematic_code/inefficient_data_loading_detector_tests.py',
            'description': 'InefficientDataLoadingDetector',
            'target_time_ms': 25, 
            'test_count': 10  # 3 positive + 3 negative + 4 edge
        }
    ]
    
    results = []
    
    # Measure each test suite
    for suite in test_suites:
        if Path(suite['file']).exists():
            result = measure_test_suite_time(suite['file'], suite['description'])
            result['target_time_ms'] = suite['target_time_ms']
            result['test_count'] = suite['test_count']
            results.append(result)
        else:
            print(f"\n⚠️  Test file not found: {suite['file']}")
    
    # Generate summary report
    print(f"\n📋 EXECUTION TIME SUMMARY")
    print("=" * 60)
    
    total_time = 0
    total_tests = 0
    passed_suites = 0
    
    for result in results:
        suite_name = result['description']
        exec_time = result['execution_time_ms']
        target_time = result['target_time_ms']
        test_count = result['test_count']
        success = result['success']
        
        total_time += exec_time
        total_tests += test_count
        
        if success:
            passed_suites += 1
            status = "✅ PASS" if exec_time <= target_time else "⚠️  SLOW"
            time_per_test = exec_time / test_count
            
            print(f"\n{suite_name}:")
            print(f"  Status: {status}")
            print(f"  Total time: {exec_time:.2f}ms (target: ≤{target_time}ms)")
            print(f"  Time per test: {time_per_test:.2f}ms")
            print(f"  Test count: {test_count}")
            
            if exec_time > target_time:
                print(f"  ⚠️  Exceeds target by {exec_time - target_time:.2f}ms")
        else:
            print(f"\n{suite_name}: ❌ FAILED")
            print(f"  Time before failure: {exec_time:.2f}ms")
            if 'error' in result:
                print(f"  Error: {result['error']}")
    
    # Overall summary
    print(f"\n🎯 OVERALL PERFORMANCE")
    print("-" * 40)
    print(f"Total execution time: {total_time:.2f}ms")
    print(f"Average time per test: {total_time/total_tests:.2f}ms")
    print(f"Successful test suites: {passed_suites}/{len(results)}")
    print(f"Total tests executed: {total_tests}")
    
    # Performance assessment
    if passed_suites == len(results):
        if total_time <= 200:  # Arbitrary good threshold
            print(f"\n🎉 EXCELLENT PERFORMANCE: All suites passed in {total_time:.2f}ms")
        else:
            print(f"\n✅ GOOD PERFORMANCE: All suites passed")
    else:
        print(f"\n⚠️  PERFORMANCE ISSUES: {len(results) - passed_suites} suites failed")
    
    # Recommendations
    slow_suites = [r for r in results if r['success'] and r['execution_time_ms'] > r['target_time_ms']]
    if slow_suites:
        print(f"\n💡 OPTIMIZATION RECOMMENDATIONS:")
        for suite in slow_suites:
            over_time = suite['execution_time_ms'] - suite['target_time_ms']
            print(f"  - {suite['description']}: Optimize by {over_time:.2f}ms")
    
    return results


if __name__ == "__main__":
    results = main()
    
    # Exit with appropriate code
    all_passed = all(r['success'] for r in results)
    sys.exit(0 if all_passed else 1)