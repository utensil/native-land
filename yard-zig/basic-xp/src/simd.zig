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
