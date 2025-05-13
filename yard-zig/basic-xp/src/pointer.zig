const std = @import("std");
const expect = std.testing.expect;

test "basic pointer operations" {
    var x: u8 = 1;
    const ptr = &x;  // type inferred as *u8
    ptr.* += 1;
    try expect(x == 2);
}

test "pointer mutability" {
    // Const pointer to mutable value
    var x: u8 = 5;
    const const_ptr: *const u8 = &x;
    try expect(const_ptr.* == 5);
    x = 10;
    try expect(const_ptr.* == 10);

    // Mutable pointer to mutable value
    var mut_ptr = &x;
    mut_ptr.* = 15;  // Modify through pointer
    try expect(x == 15);
    
    // Can also reassign the pointer itself
    var y: u8 = 20;
    mut_ptr = &y;    // Now points to y
    mut_ptr.* = 25;
    try expect(y == 25);
    try expect(x == 15);  // Original value unchanged
}

test "many-item pointers" {
    var buf = [_]u8{1, 2, 3, 4};
    const ptr: [*]const u8 = &buf;
    
    try expect(ptr[0] == 1);
    try expect(ptr[3] == 4);

    // Pass to function
    doubleElements(@ptrCast(&buf), buf.len);
    try expect(buf[0] == 2);
    try expect(buf[3] == 8);
}

fn doubleElements(ptr: [*]u8, len: usize) void {
    for (0..len) |i| {
        ptr[i] *= 2;
    }
}
