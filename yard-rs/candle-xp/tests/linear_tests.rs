// Tests for linear layer operations from main.rs

use anyhow::Result;
use candle_core::{DType, Device, Tensor};
use candle_nn::{Linear, Module};

#[test]
fn test_linear_layer_creation() -> Result<()> {
    let device = Device::Cpu;
    
    // Create weight and bias tensors
    let weight = Tensor::ones((10, 5), DType::F32, &device)?;
    let bias = Tensor::ones((10,), DType::F32, &device)?;
    
    // Create linear layer
    let linear = Linear::new(weight.clone(), Some(bias.clone()));
    
    // Test that the layer was created successfully
    // We can't directly access the internal weights, but we can test forward pass
    let input = Tensor::ones((3, 5), DType::F32, &device)?;
    let output = linear.forward(&input)?;
    
    assert_eq!(output.shape().dims(), &[3, 10]);
    
    Ok(())
}

#[test]
fn test_linear_layer_forward() -> Result<()> {
    let device = Device::Cpu;
    
    // Create simple weight matrix (2x3 -> 3x4)
    let weight = Tensor::ones((4, 3), DType::F32, &device)?;
    let bias = Tensor::zeros((4,), DType::F32, &device)?;
    
    let linear = Linear::new(weight, Some(bias));
    
    // Input: batch_size=2, input_features=3
    let input = Tensor::ones((2, 3), DType::F32, &device)?;
    
    // Forward pass
    let output = linear.forward(&input)?;
    
    // Output should be batch_size=2, output_features=4
    assert_eq!(output.shape().dims(), &[2, 4]);
    
    // Since input is all ones and weight is all ones, output should be all 3s (3 input features)
    let values = output.to_vec2::<f32>()?;
    for row in values {
        for &value in &row {
            assert_eq!(value, 3.0);
        }
    }
    
    Ok(())
}

#[test]
fn test_linear_layer_with_bias() -> Result<()> {
    let device = Device::Cpu;
    
    // Create weight and bias
    let weight = Tensor::zeros((2, 3), DType::F32, &device)?;
    let bias = Tensor::from_slice(&[1.0f32, 2.0], (2,), &device)?;
    
    let linear = Linear::new(weight, Some(bias));
    
    // Input
    let input = Tensor::ones((1, 3), DType::F32, &device)?;
    
    // Forward pass
    let output = linear.forward(&input)?;
    
    // Since weight is zeros, output should just be the bias
    let values = output.to_vec2::<f32>()?;
    assert_eq!(values[0], vec![1.0, 2.0]);
    
    Ok(())
}

#[test]
fn test_linear_layer_without_bias() -> Result<()> {
    let device = Device::Cpu;
    
    // Create weight without bias
    let weight = Tensor::from_slice(&[1.0f32, 2.0, 3.0, 4.0], (2, 2), &device)?;
    
    let linear = Linear::new(weight, None);
    
    // Input
    let input = Tensor::from_slice(&[1.0f32, 1.0], (1, 2), &device)?;
    
    // Forward pass
    let output = linear.forward(&input)?;
    
    // Manual calculation: [1, 1] * [[1, 2], [3, 4]] 
    // Matrix multiplication: input (1x2) * weight (2x2) = output (1x2)
    // output[0] = 1*1 + 1*3 = 4
    // output[1] = 1*2 + 1*4 = 6
    // But this is actually input * weight^T, so:
    // [1, 1] * [[1, 3], [2, 4]] = [1*1 + 1*2, 1*3 + 1*4] = [3, 7]
    let values = output.to_vec2::<f32>()?;
    assert_eq!(values[0], vec![3.0, 7.0]);
    
    Ok(())
}

#[test]
fn test_linear_layer_batch_processing() -> Result<()> {
    let device = Device::Cpu;
    
    // Create simple linear layer
    let weight = Tensor::from_slice(&[1.0f32, 2.0], (1, 2), &device)?;
    let bias = Tensor::from_slice(&[0.5f32], (1,), &device)?;
    
    let linear = Linear::new(weight, Some(bias));
    
    // Batch input
    let input = Tensor::from_slice(&[
        1.0f32, 2.0,  // First sample
        3.0, 4.0,  // Second sample
        5.0, 6.0,  // Third sample
    ], (3, 2), &device)?;
    
    // Forward pass
    let output = linear.forward(&input)?;
    
    assert_eq!(output.shape().dims(), &[3, 1]);
    
    // Manual calculations:
    // Sample 1: 1*1 + 2*2 + 0.5 = 5.5
    // Sample 2: 3*1 + 4*2 + 0.5 = 11.5
    // Sample 3: 5*1 + 6*2 + 0.5 = 17.5
    let values = output.to_vec2::<f32>()?;
    let expected = vec![vec![5.5], vec![11.5], vec![17.5]];
    
    for (actual_row, expected_row) in values.iter().zip(expected.iter()) {
        for (&actual, &expected) in actual_row.iter().zip(expected_row.iter()) {
            assert!((actual - expected).abs() < 1e-5);
        }
    }
    
    Ok(())
}

#[test]
fn test_linear_layer_shapes() -> Result<()> {
    let device = Device::Cpu;
    
    // Test various input/output shapes
    let shapes = vec![
        ((5, 3), (1, 3)),    // Single sample
        ((5, 3), (10, 3)),   // Batch of 10
        ((100, 50), (1, 50)), // Large feature dimension
    ];
    
    for ((out_features, in_features), (batch_size, input_dim)) in shapes {
        assert_eq!(in_features, input_dim, "Input dimensions must match");
        
        let weight = Tensor::randn(0f32, 1.0, (out_features, in_features), &device)?;
        let bias = Tensor::randn(0f32, 1.0, (out_features,), &device)?;
        
        let linear = Linear::new(weight, Some(bias));
        let input = Tensor::randn(0f32, 1.0, (batch_size, input_dim), &device)?;
        
        let output = linear.forward(&input)?;
        assert_eq!(output.shape().dims(), &[batch_size, out_features]);
    }
    
    Ok(())
}

#[test]
fn test_linear_layer_identity() -> Result<()> {
    let device = Device::Cpu;
    
    // Create identity matrix as weight
    let weight = Tensor::from_slice(&[
        1.0f32, 0.0,
        0.0, 1.0,
    ], (2, 2), &device)?;
    let bias = Tensor::zeros((2,), DType::F32, &device)?;
    
    let linear = Linear::new(weight, Some(bias));
    
    // Input should pass through unchanged
    let input = Tensor::from_slice(&[3.0f32, 4.0], (1, 2), &device)?;
    let output = linear.forward(&input)?;
    
    let values = output.to_vec2::<f32>()?;
    assert_eq!(values[0], vec![3.0, 4.0]);
    
    Ok(())
}