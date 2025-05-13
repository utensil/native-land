const std = @import("std");
const expect = std.testing.expect;
const meta = std.meta;

test "vector addition" {
    const x: @Vector(4, f32) = .{ 1, -10, 20, -1 };
    const y: @Vector(4, f32) = .{ 2, 10, 0, 1 };
    const z = x + y;
    try expect(meta.eql(z, @Vector(4, f32){ 3, 0, 20, 0 }));
}

test "vector indexing" {
    const x: @Vector(4, u8) = .{ 255, 0, 255, 0 };
    try expect(x[0] == 255);
    try expect(x[1] == 0);
    try expect(x[2] == 255);
    try expect(x[3] == 0);
}

test "vector scalar multiplication via splat" {
    const x: @Vector(3, f32) = .{ 12.5, 37.5, 2.5 };
    const y = x * @as(@Vector(3, f32), @splat(2));
    try expect(meta.eql(y, @Vector(3, f32){ 25, 75, 5 }));
}

test "vector looping" {
    const x = @Vector(4, u8){ 255, 0, 255, 0 };
    const sum = blk: {
        var tmp: u10 = 0;
        var i: u8 = 0;
        while (i < 4) : (i += 1) tmp += x[i];
        break :blk tmp;
    };
    try expect(sum == 510);
}

test "vector coercion to array" {
    const vec = @Vector(4, f32){ 1, 2, 3, 4 };
    const arr: [4]f32 = vec;
    try expect(arr[0] == 1);
    try expect(arr[3] == 4);
}

test "vector comparison operations" {
    const x: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    const y: @Vector(4, i32) = .{ 1, 5, 3, 0 };
    const mask = x == y;
    try expect(meta.eql(mask, @Vector(4, bool){ true, false, true, false }));
}

test "vector reduction operations" {
    const x: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    const sum = @reduce(.Add, x);
    try expect(sum == 10);
}

test "vector swizzle operations" {
    const x: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    const y = @shuffle(i32, x, undefined, [4]i32{ 3, 2, 1, 0 });
    try expect(meta.eql(y, @Vector(4, i32){ 4, 3, 2, 1 }));
}

test "vector min/max operations" {
    const x: @Vector(4, i32) = .{ 1, 5, 3, -2 };
    const y: @Vector(4, i32) = .{ 2, 3, 1, 0 };
    const min_vec = @min(x, y);
    const max_vec = @max(x, y);
    try expect(meta.eql(min_vec, @Vector(4, i32){ 1, 3, 1, -2 }));
    try expect(meta.eql(max_vec, @Vector(4, i32){ 2, 5, 3, 0 }));
}

test "vector bitwise operations" {
    const x: @Vector(4, u8) = .{ 0b1010, 0b1100, 0b1111, 0b0000 };
    const y: @Vector(4, u8) = .{ 0b1000, 0b0100, 0b1010, 0b1111 };
    const bit_and = x & y;
    const bit_or = x | y;
    const bit_xor = x ^ y;
    try expect(meta.eql(bit_and, @Vector(4, u8){ 0b1000, 0b0100, 0b1010, 0b0000 }));
    try expect(meta.eql(bit_or, @Vector(4, u8){ 0b1010, 0b1100, 0b1111, 0b1111 }));
    try expect(meta.eql(bit_xor, @Vector(4, u8){ 0b0010, 0b1000, 0b0101, 0b1111 }));
}

test "vector floating point operations" {
    const x: @Vector(4, f32) = .{ 1.5, 2.5, 3.5, 4.5 };
    const y: @Vector(4, f32) = .{ 0.5, 1.5, 2.5, 3.5 };
    const sum = x + y;
    const product = x * y;
    try expect(meta.eql(sum, @Vector(4, f32){ 2.0, 4.0, 6.0, 8.0 }));
    try expect(meta.eql(product, @Vector(4, f32){ 0.75, 3.75, 8.75, 15.75 }));
}

test "vector load and store operations" {
    const arr = [4]f32{ 1.0, 2.0, 3.0, 4.0 };
    const vec = @as(@Vector(4, f32), arr);
    const result: [4]f32 = vec;
    try expect(meta.eql(arr, result));
}
