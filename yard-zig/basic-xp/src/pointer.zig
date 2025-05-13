const std = @import("std");
const expect = std.testing.expect;

test "basic pointer operations" {
    var x: u8 = 1;
    const ptr: *u8 = &x;
    ptr.* += 1;
    try expect(x == 2);
}

test "null pointer detection" {
    var x: u16 = 5;
    x -= 5;
    // This would panic in safe modes:
    // var y: *u8 = @ptrFromInt(x);
}

test "const pointers" {
    const x: u8 = 1;
    const ptr: *const u8 = &x;
    // This would fail to compile:
    // ptr.* += 1;
    try expect(ptr.* == 1);
}

test "const pointer vs pointer to const" {
    // Case 1: Pointer to const value
    const const_value: u8 = 10;
    const ptr_to_const: *const u8 = &const_value;
    try expect(ptr_to_const.* == 10);
    // Can't modify through ptr_to_const since value is const
    // ptr_to_const.* = 20; // Compile error

    // Case 2: Const pointer to mutable value
    var mutable_value: u8 = 15;
    const const_ptr: *const u8 = &mutable_value;
    try expect(const_ptr.* == 15);
    // Can't modify through const_ptr even though value is mutable
    // const_ptr.* = 25; // Compile error
    // But original value can still be modified directly
    mutable_value = 25;
    try expect(const_ptr.* == 25);

    // Case 3: Non-const pointer to mutable value
    var another_value: u8 = 30;
    const mutable_ptr: *u8 = &another_value;
    mutable_ptr.* = 35;
    try expect(another_value == 35);
}

test "many-item pointer basics" {
    var buffer: [100]u8 = [_]u8{1} ** 100;
    const buffer_ptr: *[100]u8 = &buffer;
    const many_ptr: [*]u8 = buffer_ptr;

    // Can index many-item pointers
    try expect(many_ptr[0] == 1);
    try expect(many_ptr[99] == 1);

    // Can do pointer arithmetic
    const offset_ptr = many_ptr + 50;
    try expect(offset_ptr[0] == 1);
}

test "many-item pointer function parameter" {
    var data: [4]u8 = .{ 1, 2, 3, 4 };
    processBuffer(&data, data.len);
    try expect(data[0] == 2);
    try expect(data[1] == 4);
    try expect(data[2] == 6);
    try expect(data[3] == 8);
}

fn processBuffer(buffer: [*]u8, len: usize) void {
    for (0..len) |i| {
        buffer[i] *= 2;
    }
}

test "many-item pointer to single-item conversion" {
    var arr: [3]u32 = .{ 1, 2, 3 };
    const many_ptr: [*]u32 = &arr;

    // Method 1: Index then take address
    const single_ptr1: *u32 = &many_ptr[0];
    try expect(single_ptr1.* == 1);

    // Method 2: Direct cast
    const single_ptr2: *u32 = @ptrCast(many_ptr);
    try expect(single_ptr2.* == 1);
}

test "pointer coercion" {
    var x: u8 = 5;
    const ptr: *u8 = &x;
    const const_ptr: *const u8 = ptr; // Coercion allowed
    try expect(const_ptr.* == 5);
}
