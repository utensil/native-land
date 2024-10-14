#![cfg_attr(target_arch = "spirv", no_std)]
// HACK(eddyb) can't easily see warnings otherwise from `spirv-builder` builds.
#![deny(warnings)]

use glam::{UVec3, Vec4, vec4};
use spirv_std::{glam, spirv};

// Adapted from rust-gpu/examples/shaders/simplest-shader

#[spirv(fragment)]
pub fn main_fs(output: &mut Vec4) {
    *output = vec4(1.0, 0.0, 0.0, 1.0);
}

#[spirv(vertex)]
pub fn main_vs(
    #[spirv(vertex_index)] vert_id: i32,
    #[spirv(position, invariant)] out_pos: &mut Vec4,
) {
    *out_pos = vec4(
        (vert_id - 1) as f32,
        ((vert_id & 1) * 2 - 1) as f32,
        0.0,
        1.0,
    );
}

// Adapted from rust-gpu/examples/shaders/compute-shader

pub fn collatz(mut n: u32) -> Option<u32> {
    let mut i = 0;
    if n == 0 {
        return None;
    }
    while n != 1 {
        n = if n % 2 == 0 {
            n / 2
        } else {
            // Overflow? (i.e. 3*n + 1 > 0xffff_ffff)
            if n >= 0x5555_5555 {
                return None;
            }
            // TODO: Use this instead when/if checked add/mul can work: n.checked_mul(3)?.checked_add(1)?
            3 * n + 1
        };
        i += 1;
    }
    Some(i)
}

// LocalSize/numthreads of (x = 64, y = 1, z = 1)
#[spirv(compute(threads(64)))]
pub fn main_cs(
    #[spirv(global_invocation_id)] id: UVec3,
    #[spirv(storage_buffer, descriptor_set = 0, binding = 0)] prime_indices: &mut [u32],
) {
    let index = id.x as usize;
    prime_indices[index] = collatz(prime_indices[index]).unwrap_or(u32::MAX);
}