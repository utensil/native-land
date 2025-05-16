const std = @import("std");
const expect = std.testing.expect;
const mem = std.mem;

// This function can be used both at compile-time and runtime
fn factorial(n: u64) u64 {
    if (n == 0) return 1;
    return n * factorial(n - 1);
}

// Demonstrate compile-time evaluation
const compile_time_result = factorial(5);

// Generate a lookup table at compile-time
const sin_table = blk: {
    var table: [360]f32 = undefined;
    for (0..360) |i| {
        const radians = @as(f32, @floatFromInt(i)) * std.math.pi / 180.0;
        table[i] = @sin(radians);
    }
    break :blk table;
};

// Compile-time type generator based on size
fn Vector(comptime size: usize, comptime T: type) type {
    return struct {
        data: [size]T,

        const Self = @This();

        pub fn add(self: Self, other: Self) Self {
            var result: Self = undefined;
            for (0..size) |i| {
                result.data[i] = self.data[i] + other.data[i];
            }
            return result;
        }
    };
}

// Matrix type with compile-time dimensions
fn Matrix(comptime rows: usize, comptime cols: usize) type {
    return struct {
        data: [rows][cols]f32,

        pub fn zero() @This() {
            return .{ .data = .{.{0} ** cols} ** rows };
        }
    };
}

test "comptime advanced examples" {
    // Test pre-computed sin table
    try expect(sin_table[0] == 0.0);
    try expect(@abs(sin_table[90] - 1.0) < 0.001);
    
    // Test generated vector type
    const Vec3f = Vector(3, f32);
    const v1 = Vec3f{ .data = .{ 1.0, 2.0, 3.0 } };
    const v2 = Vec3f{ .data = .{ 4.0, 5.0, 6.0 } };
    const v3 = v1.add(v2);
    try expect(v3.data[0] == 5.0);
    
    // Test matrix type
    const Mat3x3 = Matrix(3, 3);
    const m = Mat3x3.zero();
    try expect(m.data[0][0] == 0.0);
}

// Compile-time string manipulation
test "comptime string processing" {
    const input = "Hello, World!";
    const reversed = comptime blk: {
        var result: [input.len]u8 = undefined;
        for (input, 0..) |char, i| {
            result[input.len - 1 - i] = char;
        }
        break :blk result;
    };
    try expect(mem.eql(u8, &reversed, "!dlroW ,olleH"));
}

// Dynamic field access at compile time
test "comptime field access" {
    const Point = struct {
        x: i32 = 10,
        y: i32 = 20,
        z: i32 = 30,
    };

    const fields = [_][]const u8{ "x", "y", "z" };
    const values = comptime blk: {
        var result: [fields.len]i32 = undefined;
        for (fields, 0..) |field, i| {
            result[i] = @field(Point{}, field);
        }
        break :blk result;
    };

    try expect(values[0] == 10); // x
    try expect(values[1] == 20); // y
    try expect(values[2] == 30); // z
}

test "factorial at compile-time and runtime" {
    // Compile-time evaluation
    try expect(compile_time_result == 120);
    
    // Runtime evaluation
    const runtime_result = factorial(5);
    try expect(runtime_result == 120);
    
    // Verify they're equal
    try expect(compile_time_result == runtime_result);
}
