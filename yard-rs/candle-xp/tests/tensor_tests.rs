// Tests for basic tensor operations from main.rs

use anyhow::Result;
use candle_core::{DType, Device, Tensor};

#[test]
fn test_tensor_creation() -> Result<()> {
    let device = Device::Cpu;

    // Test randn tensor creation
    let tensor = Tensor::randn(0f32, 1.0, (784, 100), &device)?;
    assert_eq!(tensor.shape().dims(), &[784, 100]);
    assert_eq!(tensor.dtype(), DType::F32);
    // Note: Device doesn't implement PartialEq, so we can't directly compare

    Ok(())
}

#[test]
fn test_tensor_zeros() -> Result<()> {
    let device = Device::Cpu;

    // Test zeros tensor creation (similar to the input_ids in main.rs)
    let tensor = Tensor::zeros((3, 768), DType::F32, &device)?;
    assert_eq!(tensor.shape().dims(), &[3, 768]);

    // Verify all values are zero
    let values = tensor.to_vec2::<f32>()?;
    assert_eq!(values.len(), 3);
    assert_eq!(values[0].len(), 768);

    for row in values {
        for &value in &row {
            assert_eq!(value, 0.0);
        }
    }

    Ok(())
}

#[test]
fn test_tensor_ones() -> Result<()> {
    let device = Device::Cpu;

    // Test ones tensor creation
    let tensor = Tensor::ones((2, 3), DType::F32, &device)?;
    assert_eq!(tensor.shape().dims(), &[2, 3]);

    // Verify all values are one
    let values = tensor.to_vec2::<f32>()?;
    for row in values {
        for &value in &row {
            assert_eq!(value, 1.0);
        }
    }

    Ok(())
}

#[test]
fn test_matrix_multiplication() -> Result<()> {
    let device = Device::Cpu;

    // Create two matrices for multiplication
    let a = Tensor::ones((2, 3), DType::F32, &device)?;
    let b = Tensor::ones((3, 4), DType::F32, &device)?;

    // Multiply them
    let result = a.matmul(&b)?;

    // Check shape
    assert_eq!(result.shape().dims(), &[2, 4]);

    // Check values (should be 3.0 everywhere since we're multiplying ones)
    let values = result.to_vec2::<f32>()?;
    for row in values {
        for &value in &row {
            assert_eq!(value, 3.0);
        }
    }

    Ok(())
}

#[test]
fn test_relu_activation() -> Result<()> {
    let device = Device::Cpu;

    // Create tensor with both positive and negative values
    let data = vec![-2.0f32, -1.0, 0.0, 1.0, 2.0, 3.0];
    let tensor = Tensor::from_slice(&data, (2, 3), &device)?;

    // Apply ReLU
    let result = tensor.relu()?;

    // Check that negative values become 0, positive values remain
    let values = result.to_vec2::<f32>()?;
    let expected = vec![vec![0.0, 0.0, 0.0], vec![1.0, 2.0, 3.0]];

    assert_eq!(values, expected);

    Ok(())
}

#[test]
fn test_tensor_from_slice() -> Result<()> {
    let device = Device::Cpu;

    // Test creating tensor from slice (similar to how weights might be loaded)
    let data = vec![1.0f32, 2.0, 3.0, 4.0, 5.0, 6.0];
    let tensor = Tensor::from_slice(&data, (2, 3), &device)?;

    assert_eq!(tensor.shape().dims(), &[2, 3]);

    let values = tensor.to_vec2::<f32>()?;
    let expected = vec![vec![1.0, 2.0, 3.0], vec![4.0, 5.0, 6.0]];

    assert_eq!(values, expected);

    Ok(())
}

#[test]
fn test_tensor_dtype_conversion() -> Result<()> {
    let device = Device::Cpu;

    // Test different data types
    let tensor_f32 = Tensor::zeros((2, 2), DType::F32, &device)?;
    assert_eq!(tensor_f32.dtype(), DType::F32);

    let tensor_f64 = Tensor::zeros((2, 2), DType::F64, &device)?;
    assert_eq!(tensor_f64.dtype(), DType::F64);

    Ok(())
}

#[test]
fn test_tensor_random_properties() -> Result<()> {
    let device = Device::Cpu;

    // Test that randn produces different values (very unlikely to be identical)
    let tensor1 = Tensor::randn(0f32, 1.0, (3, 3), &device)?;
    let tensor2 = Tensor::randn(0f32, 1.0, (3, 3), &device)?;

    let values1 = tensor1.to_vec2::<f32>()?;
    let values2 = tensor2.to_vec2::<f32>()?;

    // Check that at least some values are different
    let mut found_difference = false;
    for (row1, row2) in values1.iter().zip(values2.iter()) {
        for (&v1, &v2) in row1.iter().zip(row2.iter()) {
            if (v1 - v2).abs() > 1e-6 {
                found_difference = true;
                break;
            }
        }
        if found_difference {
            break;
        }
    }

    assert!(
        found_difference,
        "Random tensors should produce different values"
    );

    Ok(())
}
