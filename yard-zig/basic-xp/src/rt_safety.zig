const std = @import("std");
const expect = std.testing.expect;

test "array bounds check" {
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = undefined;
    // Force runtime evaluation of index
    @as(*volatile u8, &index).* = 5;
    _ = a[2]; // OK
    // _ = a[index]; // Will panic at runtime
}

test "integer overflow check" {
    var x: u8 = 255;
    x += 0; // OK
    // x += 1; // Will panic;
}

test "null pointer dereference check" {
    var ptr: ?*u32 = null;
    // Force runtime evaluation
    @as(*volatile ?*u32, &ptr).* = null;
    // _ = ptr.?.*; // Will panic at runtime
}

test "unreachable code check" {
    const x: i32 = 1;
    _ = x;
    // _ = if (x == 2) 5 else unreachable; // Will panic
}

test "type coercion check" {
    const x: u32 = 300;
    _ = @as(u16, @intCast(x)); // OK
    // _ = @as(u8, @intCast(x)); // Will panic if value doesn't fit
}

test "division by zero check" {
    const x: i32 = 1;
    const y: i32 = 0;
    _ = y / x; // OK
    // _ = x / y; // Will panic
}

test "invalid enum cast check" {
    const E = enum { a, b, c };
    _ = @as(E, @enumFromInt(2)); // OK
    // _ = @as(E, @enumFromInt(5)); // Will panic
}

test "slice bounds check" {
    var buf: [10]u8 = undefined;
    _ = buf[0..5]; // OK
    // _ = buf[5..15]; // Will panic
}

test "sentinel mismatch check" {
    const S = struct {
        fn check(ptr: [*:0]const u8) void {
            // This will verify the sentinel exists at runtime
            _ = ptr[5]; // Access sentinel position
        }
    };

    // Correct case (with sentinel)
    {
        var buf: [6:0]u8 = undefined;
        @memcpy(buf[0..5], "hello");
        buf[5] = 0; // Proper null terminator
        S.check(&buf); // Works fine
    }

    // Incorrect case (missing sentinel)
    {
        var buf = "hello".*; // No null terminator
        // Verify length is correct (5 bytes) and contents
        try expect(buf.len == 5);
        try expect(std.mem.eql(u8, &buf, "hello"));
        // This would fail at runtime if uncommented:
        // S.check(&buf); // Would panic when accessing buf[5]
    }
}

test "runtime safety disabled" {
    @setRuntimeSafety(false);

    // Array bounds check disabled
    {
        const a = [3]u8{ 1, 2, 3 };
        var index: u8 = undefined;
        // Force runtime evaluation of index
        @as(*volatile u8, &index).* = 5;
        _ = a[index]; // Won't panic with safety off
    }

    // Integer overflow disabled
    {
        var x: u8 = 255;
        x += 1; // Won't panic with safety off
        // now x should be 0
        try expect(x == 0);
    }
}
