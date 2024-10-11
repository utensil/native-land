use cubecl::prelude::*;
use cubecl::codegen::Compiler;
use cubecl::ExecutionMode::Unchecked;

#[cube(launch_unchecked,create_dummy_kernel)]
fn gelu_array<F: Float>(input: &Array<Line<F>>, output: &mut Array<Line<F>>) {
    if ABSOLUTE_POS < input.len() {
        output[ABSOLUTE_POS] = gelu_scalar::<F>(input[ABSOLUTE_POS]);
    }
}

#[cube]
fn gelu_scalar<F: Float>(x: Line<F>) -> Line<F> {
    // Execute the sqrt function at comptime.
    let sqrt2 = F::new(comptime!(2.0f32.sqrt()));
    let tmp = x / Line::new(sqrt2);

    x * (Line::erf(tmp) + 1.0) / 2.0
}

pub fn gelu_shader<R: Runtime>(device: &R::Device) -> String {
    let client = R::client(device);
    let input_handle = client.empty(1);

    // adapted from
    // - https://github.com/tracel-ai/cubecl/blob/main/crates/cubecl-wgpu/tests/common.rs
    // - https://github.com/tracel-ai/cubecl/blob/main/crates/cubecl-wgpu/tests/main.rs 

    let knl = gelu_array::create_dummy_kernel::<f32, R>(
        CubeCount::Static(1, 1, 1),
        CubeDim::new(1, 1, 1),
        unsafe { ArrayArg::from_raw_parts(&input_handle, 1, 1) },
        unsafe { ArrayArg::from_raw_parts(&input_handle, 1, 1) },
    );

    let knldef = knl.define();

    // println!("{:?}", knldef.body);

    let compiled = R::Compiler::compile(knldef, Unchecked);

    // println!("{}", compiled);

    format!("{}", compiled)
}

pub fn gelu_launch<R: Runtime>(device: &R::Device) -> Vec<f32> {
    let client = R::client(device);
    let input = &[-1., 0., 1., 5.];
    let vectorization = 4;
    let output_handle = client.empty(input.len() * core::mem::size_of::<f32>());
    let input_handle = client.create(f32::as_bytes(input));

    unsafe {
        gelu_array::launch_unchecked::<f32, R>(
            &client,
            CubeCount::Static(1, 1, 1),
            CubeDim::new(input.len() as u32 / vectorization, 1, 1),
            ArrayArg::from_raw_parts(&input_handle, input.len(), vectorization as u8),
            ArrayArg::from_raw_parts(&output_handle, input.len(), vectorization as u8),
        )
    };

    let bytes = client.read(output_handle.binding());
    let output = f32::from_bytes(&bytes);

    output.to_vec()
}
