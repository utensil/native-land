const std = @import("std");
const expect = std.testing.expect;

// https://zig.guide/standard-library/allocators/

// Whenever this allocator makes an allocation, it will ask your OS for entire pages of memory
test "page_alloc" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

test "fixed buffer allocator" {
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

test "fixed buffer allocator out of memory" {
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const memory = allocator.alloc(u8, 101);
    try std.testing.expectError(error.OutOfMemory, memory);
}

// std.heap.ArenaAllocator takes in a child allocator and allows you to allocate many times and only free once.
test "arena allocator" {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var arena = std.heap.ArenaAllocator.init(fba.allocator());
    defer arena.deinit(); // This frees all allocations made with the arena

    const allocator = arena.allocator();

    // Allocate multiple times
    const mem1 = try allocator.alloc(u8, 100);
    const mem2 = try allocator.alloc(u8, 200);
    const mem3 = try allocator.alloc(u8, 300);

    try expect(mem1.len == 100);
    try expect(mem2.len == 200);
    try expect(mem3.len == 300);

    // All allocations are freed when arena.deinit() is called
}

// test std.heap.GeneralPurposeAllocator AI!
