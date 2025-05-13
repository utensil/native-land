const std = @import("std");
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const eql = std.mem.eql;
const Allocator = std.mem.Allocator;

// inspired by https://gencmurat.com/en/posts/memory-safety-features-in-zig/

test "no hidden control flow with try" {
    // Demonstrates explicit error handling
    const file = std.fs.cwd().openFile("nonexistent.txt", .{}) catch |err| {
        try expect(err == error.FileNotFound);
        return;
    };
    defer file.close();
}

fn mightFail(cond: bool) !u32 {
    if (cond) {
        return 42;
    } else {
        return error.Fail;
    }
}

test "IIFE (Immediately Invoked Function Expression)" {
    // Basic IIFE calculation
    const area = blk: {
        const radius = 10;
        const pi = 3.14159;
        break :blk pi * radius * radius;
    };
    try expect(area > 314.0 and area < 315.0);

    // IIFE with error handling
    const parsed = blk: {
        const res = std.fmt.parseInt(u32, "123", 10) catch |err| {
            try expect(err == error.InvalidCharacter);
            break :blk 0;
        };
        break :blk res;
    };
    try expect(parsed == 123);

    // IIFE with memory operations
    const buf = blk: {
        var tmp: [100]u8 = undefined;
        @memset(&tmp, 0xAA);
        break :blk tmp;
    };
    try expect(buf[50] == 0xAA);
}

test "comprehensive error handling" {
    const result = mightFail(false) catch |err| {
        try expect(err == error.Fail);
        return;
    };
    try expect(result == 42);
}

test "compile-time safety checks" {
    // Array bounds checking at compile time
    const arr = [_]u8{ 1, 2, 3 };
    const val = arr[2]; // OK
    // arr[3] would be compile error
    try expect(val == 3);
}

test "runtime bounds checking" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try list.append(42);
    try expect(list.items[0] == 42);

    // Test out of bounds access
    if (list.items.len > 1) {
        try expect(list.items[1] == 0); // Shouldn't reach here
    }

    // Test array bounds
    var arr = [_]u8{ 1, 2, 3 };
    const index: usize = 1;
    const val = arr[index]; // Runtime bounds checked
    arr[index] = 4; // OK
    try expect(val == 2);

    // Should panic in debug/safe modes
    // arr[3] = 0;
}

test "defer for guaranteed cleanup" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const mem = try allocator.alloc(u8, 100);
    defer allocator.free(mem); // Will run even if later code fails

    try expect(mem.len == 100);
}

test "optional types prevent null dereferences" {
    const maybe_num: ?u32 = null;
    if (maybe_num) |num| {
        try expect(num == 42); // Shouldn't reach here
        try expect(false);
    } else {
        try expect(true); // Should reach here
    }

    const real_num: ?u32 = 42;
    if (real_num) |num| {
        try expect(num == 42); // Should reach here
    } else {
        try expect(false); // Shouldn't reach here
    }
}

test "sentinel-terminated arrays" {
    const allocator = std.testing.allocator;

    // Literal strings are null-terminated
    const str: [:0]const u8 = "hello";
    try expect(str.len == 5);
    try expect(str[5] == 0); // Sentinel value

    // Manually created sentinel-terminated array
    var buf: [6:0]u8 = undefined;
    buf[0..5].* = "hello".*;
    buf[5] = 0;
    try expect(buf[5] == 0);

    // Dynamic allocation with sentinel
    const dyn_str = try allocator.allocSentinel(u8, 5, 0);
    defer allocator.free(dyn_str);
    @memcpy(dyn_str[0..5], "hello");
    try expect(dyn_str[5] == 0);
}

test "explicit allocators" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    // Use var since we'll modify the pointer
    var mem = try allocator.alloc(u8, 100);
    defer allocator.free(mem); // Will free final allocation

    try expect(mem.len == 100);

    // Realloc and update pointer
    mem = try allocator.realloc(mem, 200);
    try expect(mem.len == 200);

    // Test the expanded memory
    @memset(mem, 0xAA);
    try expect(mem[150] == 0xAA);
}

fn fibonacci(n: u32) u32 {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "thread safety with allocators" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var thread = try std.Thread.spawn(.{}, struct {
        fn f(alloc: Allocator) !void {
            const mem = try alloc.alloc(u8, 100);
            defer alloc.free(mem);
            @memset(mem, 42);
        }
    }.f, .{allocator});

    thread.join(); // No try needed since join() doesn't return error

    // Main thread can still use allocator
    const mem = try allocator.alloc(u8, 100);
    defer allocator.free(mem);
}

test "comptime function evaluation" {
    const fib = comptime fibonacci(10);
    try expect(fib == 55);
}

fn createResource(allocator: Allocator) !Resource {
    const mem1 = try allocator.alloc(u8, 100);
    errdefer allocator.free(mem1);

    const mem2 = try allocator.alloc(u8, 200);
    errdefer allocator.free(mem2);

    return Resource{
        .mem1 = mem1,
        .mem2 = mem2,
        .allocator = allocator,
    };
}

fn createErrorResource(allocator: Allocator) !ErrorResource {
    const mem = try allocator.alloc(u8, 100);
    errdefer allocator.free(mem);

    return error.TestError; // Force error to test errdefer
}

const Resource = struct {
    mem1: []u8,
    mem2: []u8,
    allocator: Allocator,

    fn deinit(self: @This()) void {
        self.allocator.free(self.mem1);
        self.allocator.free(self.mem2);
    }
};

const ErrorResource = struct {
    mem: []u8,
    allocator: Allocator,

    fn deinit(self: @This()) void {
        self.allocator.free(self.mem);
    }
};

test "errdefer for error cleanup - partial failure" {
    const PartialResource = struct {
        mem1: []u8,
        mem2: []u8,
        allocator: Allocator,

        fn deinit(self: @This()) void {
            self.allocator.free(self.mem1);
            self.allocator.free(self.mem2);
        }
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result = (struct {
        fn create(allocator: Allocator) !PartialResource {
            const mem1 = try allocator.alloc(u8, 100);
            errdefer allocator.free(mem1);

            // Force error after first allocation
            return error.TestError;
        }
    }).create(gpa.allocator());

    try expectError(error.TestError, result);
}

test "errdefer for error cleanup" {
    // Test successful path
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();
        const res = try createResource(allocator);
        defer res.deinit();
        try expect(res.mem1.len == 100);
        try expect(res.mem2.len == 200);
    }

    // Test error path
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{
            .enable_memory_limit = true,
            .stack_trace_frames = 0,
        }){};
        const allocator = gpa.allocator();

        defer {
            const leak_check = gpa.deinit();
            if (leak_check == .leak) {
                std.debug.print("Memory leak detected!\n", .{});
            }
            // Can't use try in defer, so we'll check the result separately
            std.debug.assert(leak_check == .ok); // Verify no leaks
        }

        const result = createErrorResource(allocator);

        try expect(result == error.TestError);
    }
}

