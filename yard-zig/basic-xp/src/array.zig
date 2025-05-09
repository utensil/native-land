const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

// there are too many try AI!
test "basic arraylist operations" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();

    // Test append with loop
    const hello = "Hello";
    for (hello) |char| {
        try list.append(char);
    }
    try expect(eql(u8, list.items, hello));

    // Test appendSlice and verify
    try list.appendSlice(" World!");
    try expect(eql(u8, list.items, "Hello World!"));

    // Test insert and verify
    try list.insert(5, ',');
    try expect(eql(u8, list.items, "Hello, World!"));

    // Test pop and verify
    const last_char = list.pop();
    try expect(last_char == '!' and eql(u8, list.items, "Hello, World"));
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
