@group(0)
@binding(0)
var<storage, read_write> input_0_global: array<f32>;

@group(0)
@binding(1)
var<storage, read_write> output_0_global: array<f32>;

@group(0)
@binding(2)
var<storage, read_write> info: array<u32>;

const WORKGROUP_SIZE_X = 1u;
const WORKGROUP_SIZE_Y = 1u;
const WORKGROUP_SIZE_Z = 1u;

@compute
@workgroup_size(1, 1, 1)
fn gelu_array_f32(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(num_workgroups) num_workgroups: vec3<u32>,
) {
let id = (global_id.z * num_workgroups.x * WORKGROUP_SIZE_X * num_workgroups.y * WORKGROUP_SIZE_Y) + (global_id.y * num_workgroups.x * WORKGROUP_SIZE_X) + global_id.x;
let l_0 = info[2u];
let l_1 = id < l_0;
if l_1 {
let l_2 = input_0_global[id];
let l_3 = l_2 / 1.41421353816986083984375f;
var l_mut_26: bool;
let l_8 = abs(l_3);
let l_9 = 0.3275910913944244384765625f * l_8;
let l_10 = 1f + l_9;
let l_11 = 1f / l_10;
let l_12 = 1.0614054203033447265625f * l_11;
let l_13 = l_12 + -1.4531519412994384765625f;
let l_14 = l_13 * l_11;
let l_15 = l_14 + 1.4214136600494384765625f;
let l_16 = l_15 * l_11;
let l_17 = l_16 + -0.2844967544078826904296875f;
let l_18 = l_17 * l_11;
let l_19 = l_18 + 0.254829585552215576171875f;
let l_20 = l_19 * l_11;
let l_21 = -l_8;
let l_22 = l_21 * l_8;
let l_23 = exp(l_22);
let l_24 = l_20 * l_23;
let l_25 = 1f - l_24;
l_mut_26 = l_3 < 0f;
let l_27 = -l_25;
let l_28 = select(l_25, l_27, l_mut_26);
let l_4 = l_28;
let l_5 = l_4 + 1f;
let l_6 = l_2 * l_5;
let l_7 = l_6 / 2f;
output_0_global[id] = l_7;
}
}
