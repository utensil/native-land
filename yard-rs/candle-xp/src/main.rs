// Adapted from
// - https://huggingface.github.io/candle/guide/hello_world.html
// - https://huggingface.github.io/candle/inference/hub.html

use anyhow::{anyhow, Result};
use candle_core::{Device, Tensor, DType};
use hf_hub::api::tokio::Api;
use candle_nn::{Linear, Module};
use memmap2::Mmap;
use std::fs;

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
const USE_MMAP : bool = true;

async fn task() -> Result<()> {
    // Use Device::new_cuda(0)?; to use the GPU.
    let device = Device::Cpu;

    let first = Tensor::randn(0f32, 1.0, (784, 100), &device)?;
    let second = Tensor::randn(0f32, 1.0, (100, 10), &device)?;
    let model = Model { first, second };

    let dummy_image = Tensor::randn(0f32, 1.0, (1, 784), &device)?;

    let digit = model.forward(&dummy_image)?;
    println!("Digit {digit:?} digit");

    let api = Api::new()?;
    let repo = api.model("bert-base-uncased".to_string());

    println!("Downloading weights...");

    let weights_filename = repo.get("model.safetensors").await?;

    println!("Downloaded weights to {}", weights_filename.display());

    let weights = if USE_MMAP {
        let file = fs::File::open(weights_filename)?;
        let mmap = unsafe { Mmap::map(&file)? };
        candle_core::safetensors::load_buffer(&mmap[..], &Device::Cpu)?
    } else {
        candle_core::safetensors::load(weights_filename, &Device::Cpu)?
    };

    let weight = weights.get("bert.encoder.layer.0.attention.self.query.weight")
        .ok_or(anyhow!("fail to get weight"))?;
    let bias = weights.get("bert.encoder.layer.0.attention.self.query.bias")
        .ok_or(anyhow!("fail to get bias"))?;
    
    let linear = Linear::new(weight.clone(), Some(bias.clone()));
    
    let input_ids = Tensor::zeros((3, 768), DType::F32, &Device::Cpu)?;
    let output = linear.forward(&input_ids)?;

    println!("{:?}", output);

    Ok(())
}

fn main() -> Result<()> {
    let rt = tokio::runtime::Runtime::new()?;
    rt.block_on(task())
}