const std = @import("std");
const expect = std.testing.expect;
const mem = std.mem;

test "comptime integers" {
    const a: comptime_int = 5;
    const b: comptime_int = 10;
    const c = a + b;
    try expect(c == 15);
    try expect(@TypeOf(c) == comptime_int);
}

test "comptime float" {
    const a: comptime_float = 5.5;
    const b: comptime_float = 10.5;
    const c = a + b;
    try expect(c == 16.0);
    try expect(@TypeOf(c) == comptime_float);
}

test "comptime array" {
    const arr = [5]u8{ 1, 2, 3, 4, 5 };
    try expect(arr.len == 5);
    try expect(arr[0] == 1);
    try expect(arr[4] == 5);
}

test "comptime struct" {
    const Point = struct {
        x: i32,
        y: i32,
    };
    const p = Point{ .x = 10, .y = 20 };
    try expect(p.x == 10);
    try expect(p.y == 20);
}

fn do_fib(n: u32) u32 {
    if (n <= 1) return n;
    return do_fib(n - 1) + do_fib(n - 2);
}

test "comptime function evaluation" {
    const fib = comptime do_fib(10);
    try expect(fib == 55);
}

test "comptime string concatenation" {
    const hello = "Hello";
    const world = "World";
    const hello_world = hello ++ " " ++ world;
    try expect(mem.eql(u8, hello_world, "Hello World"));
}

test "comptime type creation" {
    const MyInt = comptime blk: {
        if (@sizeOf(usize) == 8) {
            break :blk u64;
        } else {
            break :blk u32;
        }
    };
    try expect(@TypeOf(@as(MyInt, 0)) == u64);
}

test "comptime branching" {
    const x = comptime if (true) 10 else 20;
    try expect(x == 10);
}

test "comptime loops" {
    const sum = comptime blk: {
        var res: u32 = 0;
        for (1..6) |i| {
            res += i;
        }
        break :blk res;
    };
    try expect(sum == 15);
}
