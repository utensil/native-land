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
    var arr = [_]u8{ 1, 2, 3 };
    const index: usize = 1;
    const val = arr[index]; // Runtime bounds checked
    arr[index] = 4; // OK
    try expect(val == 2);
    // accessing arr[3] would cause a runtime error
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
        // This branch only runs if maybe_num is not null
        // Shouldn't reach here
        expect(num == 42);
        try expect(false);
    } else {
        try expect(true); // Should reach here
    }
}

test "sentinel-terminated arrays" {
    const str: [:0]const u8 = "hello";
    try expect(str.len == 5);
    try expect(str[5] == 0); // Sentinel value
}

test "explicit allocators" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const mem1 = try allocator.alloc(u8, 100);
    const mem2 = try allocator.alloc(u8, 200);
    try expect(mem1.len == 100);
    try expect(mem2.len == 200);
    // Both freed when arena is deinit
}

fn fibonacci(n: u32) u32 {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
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
