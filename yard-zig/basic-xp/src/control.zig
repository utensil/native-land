const std = @import("std");
const expect = std.testing.expect;

test "if expressions" {
    const a = true;
    const x = if (a) 1 else 2;
    try expect(x == 1);

    // If as expression with blocks
    const y = if (a) blk: {
        const temp = 10;
        break :blk temp * 2;
    } else 0;
    try expect(y == 20);
}

test "while loops" {
    // Basic while
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    try expect(i == 128);

    // While with continue expression
    var sum: u8 = 0;
    var j: u8 = 1;
    while (j <= 10) : (j += 1) {
        sum += j;
    }
    try expect(sum == 55);

    // While with continue
    var odd_sum: u8 = 0;
    var k: u8 = 0;
    while (k <= 10) : (k += 1) {
        if (k % 2 == 0) continue; // Skip even numbers
        odd_sum += k;
    }
    try expect(odd_sum == 25); // 1 + 3 + 5 + 7 + 9
}

test "for loops" {
    const nums = [_]u8{ 10, 20, 30 };
    var sum: u8 = 0;

    // Basic for
    for (nums) |num| {
        sum += num;
    }
    try expect(sum == 60);

    // For with index
    sum = 0;
    for (nums, 0..) |num, index| {
        sum += num + @as(u8, @intCast(index));
    }
    try expect(sum == 63); // 10+0 + 20+1 + 30+2
}

test "switch expressions" {
    const x: i8 = 10;
    const result = switch (x) {
        -1...1 => "small",
        10, 100 => "special",
        else => "other",
    };
    try expect(std.mem.eql(u8, result, "special"));

    // Switch with blocks
    const y = switch (x) {
        10 => blk: {
            const temp = x * 2;
            break :blk temp;
        },
        else => x,
    };
    try expect(y == 20);
}

test "labelled blocks and loops" {
    // Labelled block
    const count = blk: {
        var sum: u32 = 0;
        var i: u32 = 0;
        while (i < 10) : (i += 1) sum += i;
        break :blk sum;
    };
    try expect(count == 45);

    // Labelled loop with break/continue
    outer: for (1..10) |i| {
        for (1..5) |j| {
            if (i == 5 and j == 3) break :outer;
            if (j == 2) continue;
        }
    }
}

test "loops as expressions" {
    var i: u32 = 1;
    const hasNumber = while (i <= 10) : (i += 1) {
        if (i == 5) break true;
    } else false;
    try expect(hasNumber);
}

test "payload captures" {
    // Optional payload
    const maybe_num: ?u32 = 42;
    if (maybe_num) |num| {
        try expect(num == 42);
    } else {
        unreachable;
    }

    // Error union payload
    const result: error{Test}!u32 = 100;
    if (result) |value| {
        try expect(value == 100);
    } else |err| {
        _ = err catch {};
        unreachable;
    }

    // Pointer capture in for loop
    var data = [_]u8{ 1, 2, 3 };
    for (&data) |*byte| byte.* += 1;
    try expect(data[0] == 2);
    try expect(data[1] == 3);
    try expect(data[2] == 4);
}

test "inline loops" {
    const types = [_]type{ i32, f32, u8 };
    var sum: usize = 0;
    inline for (types) |T| {
        sum += @sizeOf(T);
    }
    try expect(sum == 9); // 4 + 4 + 1
}

// https://www.reddit.com/r/Zig/comments/1lpqe3a/what_is_the_simplest_and_most_elegant_zig_code/

fn activeFieldSize(u: anytype) usize {
    return switch (u) {
        inline else => |field| @sizeOf(@TypeOf(field)),
    };
}

test "inline else in switch" {
    const TestUnion = union(enum) {
        small: u8,
        large: i64,
        text: []const u8,
    };

    const small_variant = TestUnion{ .small = 42 };
    const large_variant = TestUnion{ .large = 12345 };
    const text_variant = TestUnion{ .text = "hello" };

    try expect(activeFieldSize(small_variant) == 1); // u8
    try expect(activeFieldSize(large_variant) == 8); // i64
    try expect(activeFieldSize(text_variant) == 16); // []const u8 (ptr + len)

    // Works at compile time too
    const ct_variant = comptime TestUnion{ .small = 255 };
    comptime {
        try expect(activeFieldSize(ct_variant) == 1);
    }
}
test "metaprogramming with inline for and type introspection" {
    // ECS component system inspired by roguelike example
    const Component = struct { name: []const u8, field_count: u32 };
    
    const Health = struct { max_hp: i32, current_hp: i32 };
    const Position = struct { x: f32, y: f32, z: f32 };
    const Damage = struct { attack: i32 };
    
    const ComponentInfo = struct { name: []const u8, typ: type };
    const component_types = [_]ComponentInfo{
        .{ .name = "Health", .typ = Health },
        .{ .name = "Position", .typ = Position },
        .{ .name = "Damage", .typ = Damage },
    };
    
    const json_components = [_]Component{
        .{ .name = "Health", .field_count = 2 },
        .{ .name = "Position", .field_count = 3 },
        .{ .name = "Damage", .field_count = 1 },
    };
    
    var matched_components: u32 = 0;
    for (json_components) |component| {
        inline for (component_types) |info| {
            if (std.mem.eql(u8, component.name, info.name)) {
                const type_info = @typeInfo(info.typ);
                const actual_fields = type_info.@"struct".fields.len;
                try expect(actual_fields == component.field_count);
                matched_components += 1;
            }
        }
    }
    
    try expect(matched_components == 3);
}
