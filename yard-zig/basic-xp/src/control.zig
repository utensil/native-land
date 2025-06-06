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
    var data = [_]u8{1, 2, 3};
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
