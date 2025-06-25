// Tests for the neural network model from main.rs

use anyhow::Result;
use candle_core::{Device, Tensor};

struct Model {
    first: Tensor,
    second: Tensor,
}

impl Model {
    fn forward(&self, image: &Tensor) -> Result<Tensor> {
        let x = image.matmul(&self.first)?;
        let x = x.relu()?;
        Ok(x.matmul(&self.second)?)
    }
}

#[test]
fn test_model_creation() -> Result<()> {
    let device = Device::Cpu;

    let first = Tensor::randn(0f32, 1.0, (784, 100), &device)?;
    let second = Tensor::randn(0f32, 1.0, (100, 10), &device)?;
    let model = Model { first, second };

    // Verify the tensors have correct shapes
    assert_eq!(model.first.shape().dims(), &[784, 100]);
    assert_eq!(model.second.shape().dims(), &[100, 10]);

    Ok(())
}

#[test]
fn test_model_forward() -> Result<()> {
    let device = Device::Cpu;

    // Create model with known weights for predictable testing
    let first = Tensor::ones((784, 100), candle_core::DType::F32, &device)?;
    let second = Tensor::ones((100, 10), candle_core::DType::F32, &device)?;
    let model = Model { first, second };

    // Create dummy input
    let dummy_image = Tensor::ones((1, 784), candle_core::DType::F32, &device)?;

    // Forward pass
    let output = model.forward(&dummy_image)?;

    // Verify output shape
    assert_eq!(output.shape().dims(), &[1, 10]);

    // Verify output values (with ones, should be 784 * 100 = 78400 for each output)
    let output_values = output.to_vec2::<f32>()?;
    assert_eq!(output_values.len(), 1);
    assert_eq!(output_values[0].len(), 10);

    // Each output should be 784 (sum of input) * 100 (number of hidden units) = 78400
    for &value in &output_values[0] {
        assert!((value - 78400.0).abs() < 1e-5);
    }

    Ok(())
}

#[test]
fn test_model_forward_with_batch() -> Result<()> {
    let device = Device::Cpu;

    let first = Tensor::ones((784, 100), candle_core::DType::F32, &device)?;
    let second = Tensor::ones((100, 10), candle_core::DType::F32, &device)?;
    let model = Model { first, second };

    // Create batch of inputs
    let batch_input = Tensor::ones((3, 784), candle_core::DType::F32, &device)?;

    // Forward pass
    let output = model.forward(&batch_input)?;

    // Verify output shape for batch
    assert_eq!(output.shape().dims(), &[3, 10]);

    Ok(())
}

#[test]
fn test_model_relu_activation() -> Result<()> {
    let device = Device::Cpu;

    // Create model where first layer might produce negative values
    let first = Tensor::from_slice(&[-1.0f32; 784 * 100], (784, 100), &device)?;
    let second = Tensor::ones((100, 10), candle_core::DType::F32, &device)?;
    let model = Model { first, second };

    // Create positive input
    let input = Tensor::ones((1, 784), candle_core::DType::F32, &device)?;

    // Forward pass
    let output = model.forward(&input)?;

    // After ReLU, negative values should become 0, so final output should be 0
    let output_values = output.to_vec2::<f32>()?;
    for &value in &output_values[0] {
        assert!((value - 0.0).abs() < 1e-5);
    }

    Ok(())
}
