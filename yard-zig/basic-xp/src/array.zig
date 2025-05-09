const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

test "basic arraylist operations" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();

    // Test append
    try list.append('H');
    try list.append('e');
    try list.append('l');
    try list.append('l');
    try list.append('o');
    try expect(eql(u8, list.items, "Hello"));

    // Test appendSlice
    try list.appendSlice(" World!");
    try expect(eql(u8, list.items, "Hello World!"));

    // Test insert
    try list.insert(5, ',');
    try expect(eql(u8, list.items, "Hello, World!"));

    // Test pop
    const last_char = list.pop();
    try expect(last_char == '!');
    try expect(eql(u8, list.items, "Hello, World"));
}

test "arraylist capacity and resizing" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();

    // Initial capacity
    const initial_cap = list.capacity;
    try expect(initial_cap >= 0);

    // Test ensureTotalCapacity
    try list.ensureTotalCapacity(100);
    try expect(list.capacity >= 100);

    // Test resize
    try list.resize(5);
    try expect(list.items.len == 5);
}

test "arraylist clearing" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();

    try list.appendSlice("Test");
    try expect(list.items.len == 4);

    list.clearRetainingCapacity();
    try expect(list.items.len == 0);
    try expect(list.capacity > 0);

    list.clearAndFree();
    try expect(list.items.len == 0);
    try expect(list.capacity == 0);
}
