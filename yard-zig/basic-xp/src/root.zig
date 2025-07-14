const alloc = @import("alloc.zig");
const array = @import("array.zig");
const comptime_tests = @import("comptime.zig");
const control = @import("control.zig");
const float_precision = @import("float_precision.zig");
const pointer = @import("pointer.zig");
const rt_safety = @import("rt_safety.zig");
const safety = @import("safety.zig");
const simd = @import("simd.zig");
const string_literals = @import("string_literals.zig");

// Re-export test functions to make them discoverable
test {
    _ = alloc;
    _ = array;
    _ = comptime_tests;
    _ = control;
    _ = float_precision;
    _ = pointer;
    _ = rt_safety;
    _ = safety;
    _ = simd;
    _ = string_literals;
}
