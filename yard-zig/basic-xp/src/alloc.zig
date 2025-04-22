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
