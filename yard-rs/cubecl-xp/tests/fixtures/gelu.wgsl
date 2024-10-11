@group(0)
@binding(0)
var<storage, read_write> input_0_global: array<vec4<f32>>;

@group(0)
@binding(1)
var<storage, read_write> output_0_global: array<vec4<f32>>;

@group(0)
@binding(2)
var<storage, read_write> info: array<u32>;

const WORKGROUP_SIZE_X = 4u;
const WORKGROUP_SIZE_Y = 1u;
const WORKGROUP_SIZE_Z = 1u;

@compute
@workgroup_size(4, 1, 1)
fn main(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(num_workgroups) num_workgroups: vec3<u32>,
) {let id = (global_id.z * num_workgroups.x * WORKGROUP_SIZE_X * num_workgroups.y * WORKGROUP_SIZE_Y) + (global_id.y * num_workgroups.x * WORKGROUP_SIZE_X) + global_id.x;
let rank: u32 = info[0];
let _0 = arrayLength(&input_0_global);
let _1 = id < _0;
if _1 {
let _2 = input_0_global[id];
let _3 = _2 / 1.41421353816986083984375f;
let _4 = erf(_3);
let _5 = _4 + 1f;
let _6 = _2 * _5;
let _7 = _6 / 2f;
output_0_global[id] = _7;
}
}
/// An approximation of the error function: https://en.wikipedia.org/wiki/Error_function#Numerical_approximations
///
/// > (maximum error: 1.5×10−7)
/// > All of these approximations are valid for x ≥ 0. To use these approximations for negative x, use the fact that erf x is an odd function, so erf x = −erf(−x).
fn erf_positive_scalar(x: f32) -> f32 {
    let p = 0.3275911;
    let a1 = 0.254829592;
    let a2 = -0.284496736;
    let a3 = 1.421413741;
    let a4 = -1.453152027;
    let a5 = 1.061405429;

    let t = 1.0 / (1.0 + p * abs(x));
    let tmp = ((((a5 * t + a4) * t) + a3) * t + a2) * t + a1;

    return 1.0 - (tmp * t * exp(-x * x));
}

fn erf_scalar(x: f32) -> f32 {
    if (x < 0.0) {
        return -1.0 * erf_positive_scalar(-1.0 * x);
    }

    return erf_positive_scalar(x);
}

fn erf(x: vec4<f32>) -> vec4<f32> {
    return vec4(
       erf_scalar(x[0]),
       erf_scalar(x[1]),
       erf_scalar(x[2]),
       erf_scalar(x[3]),
    );
}
                

