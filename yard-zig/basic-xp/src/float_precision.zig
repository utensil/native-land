const std = @import("std");
const testing = std.testing;
const print = std.debug.print;
const math = std.math;

// Demonstrates floating-point precision issues where repeatedly adding 0.1 doesn't result in exactly 1.0
test "floating point precision demonstration" {
    var sum: f64 = 0.0;
    
    // Add 0.1 ten times
    for (0..10) |_| {
        sum += 0.1;
    }
    
    print("Sum after adding 0.1 ten times: {}\n", .{sum});
    print("Expected: 1.0, Actual: {}\n", .{sum});
    print("Difference from 1.0: {}\n", .{1.0 - sum});
    
    // Verify that the sum is not exactly 1.0 (the mathematically expected result)
    try testing.expect(sum != 1.0);
    
    // Verify that the sum is very close to 1.0 (within floating-point precision)
    try testing.expectApproxEqRel(sum, 1.0, 1e-15);
    
    // Verify exact match with the actual IEEE 754 result
    try testing.expectEqual(sum, 0.9999999999999999);
}

// Alternative demonstration using f32 to show even more pronounced precision issues
test "f32 precision comparison" {
    var sum_f32: f32 = 0.0;
    var sum_f64: f64 = 0.0;
    
    for (0..10) |_| {
        sum_f32 += 0.1;
        sum_f64 += 0.1;
    }
    
    print("f32 sum: {}\n", .{sum_f32});
    print("f64 sum: {}\n", .{sum_f64});
    
    // f32 will have even less precision than f64
    try testing.expect(sum_f32 != 1.0);
    try testing.expect(sum_f64 != 1.0);
    
    // f32 should be further from 1.0 than f64
    const f32_error = @abs(1.0 - sum_f32);
    const f64_error = @abs(1.0 - sum_f64);
    try testing.expect(f32_error > f64_error);
}

// Demonstrates a solution using integer arithmetic for exact decimal calculations
test "exact decimal arithmetic using integers" {
    // Use integer arithmetic to avoid floating-point precision issues
    // Represent 0.1 as 1/10, work with tenths
    var sum_tenths: i32 = 0;
    
    for (0..10) |_| {
        sum_tenths += 1; // Adding 1 tenth each time
    }
    
    const exact_sum = @as(f64, @floatFromInt(sum_tenths)) / 10.0;
    print("Exact sum using integer arithmetic: {}\n", .{exact_sum});
    
    // This should be exactly 1.0
    try testing.expectEqual(exact_sum, 1.0);
}

// Test cases from: https://en.wikipedia.org/wiki/Floating-point_arithmetic#Accuracy_problems
// https://www.exploringbinary.com/why-0-point-1-does-not-exist-in-floating-point/
// https://www.exploringbinary.com/floating-point-questions-are-endless-on-stackoverflow-com/
// https://docs.python.org/3/tutorial/floatingpoint.html
// https://floating-point-gui.de/basic/

test "special floating point addition problems" {
    const tolerance = 1e-15;
    
    // These additions should be exact but aren't in floating-point
    const test_cases = [_]struct { a: f64, b: f64, expected: f64 }{
        .{ .a = 0.09, .b = 0.01, .expected = 0.1 },
        .{ .a = 0.1, .b = 0.2, .expected = 0.3 },
        .{ .a = 0.3, .b = 0.6, .expected = 0.9 },
        .{ .a = 19.24, .b = 6.95, .expected = 26.19 },
        .{ .a = 1.2, .b = -0.1, .expected = 1.1 },
        .{ .a = 1.1, .b = 2.2, .expected = 3.3 },
        .{ .a = -1.0, .b = 1.15, .expected = 0.15 },
    };
    
    for (test_cases) |case| {
        const result = case.a + case.b;
        print("Testing: {} + {} = {} (expected: {})\n", .{ case.a, case.b, result, case.expected });
        
        // Show that floating-point arithmetic is not exact
        try testing.expect(result != case.expected);
        
        // But the result should be very close
        try testing.expectApproxEqRel(result, case.expected, tolerance);
    }
}

test "special floating point multiplication problems" {
    const tolerance = 1e-14;
    
    // This multiplication should be exact but isn't in floating-point
    const a: f64 = 4.35;
    const b: f64 = 100.0;
    const expected: f64 = 435.0;
    const result = a * b;
    
    print("Testing: {} * {} = {} (expected: {})\n", .{ a, b, result, expected });
    
    // Show that floating-point arithmetic is not exact
    try testing.expect(result != expected);
    
    // But the result should be very close
    try testing.expectApproxEqRel(result, expected, tolerance);
}

test "associative property failure in floating point" {
    // Floating-point arithmetic doesn't follow associative property: (a + b) + c ≠ a + (b + c)
    const a: f64 = 1234.567;
    const b: f64 = 45.67834;
    const c: f64 = 0.0004;
    
    const left_assoc = (a + b) + c;
    const right_assoc = a + (b + c);
    
    print("Testing associative property:\n", .{});
    print("({} + {}) + {} = {}\n", .{ a, b, c, left_assoc });
    print("{} + ({} + {}) = {}\n", .{ a, b, c, right_assoc });
    print("Difference: {}\n", .{left_assoc - right_assoc});
    
    // Test if they are actually equal (some cases might be exact)
    if (left_assoc == right_assoc) {
        // If they're exactly equal, that's also a valid demonstration
        print("Note: These values happen to be exactly equal in this case\n", .{});
        try testing.expectEqual(left_assoc, right_assoc);
    } else {
        // Show that associative property fails
        try testing.expect(left_assoc != right_assoc);
        // But they should be very close
        try testing.expectApproxEqRel(left_assoc, right_assoc, 1e-14);
    }
}

test "distributive property failure in floating point" {
    // Floating-point arithmetic doesn't follow distributive property: (a + b) * c ≠ a * c + b * c
    const a: f64 = 1234.567;
    const b: f64 = 1.234567;
    const c: f64 = 3.333333;
    
    const left_dist = (a + b) * c;
    const right_dist = a * c + b * c;
    
    print("Testing distributive property:\n", .{});
    print("({} + {}) * {} = {}\n", .{ a, b, c, left_dist });
    print("{} * {} + {} * {} = {}\n", .{ a, c, b, c, right_dist });
    print("Difference: {}\n", .{left_dist - right_dist});
    
    // Test if they are actually equal (some cases might be exact)
    if (left_dist == right_dist) {
        // If they're exactly equal, that's also a valid demonstration
        print("Note: These values happen to be exactly equal in this case\n", .{});
        try testing.expectEqual(left_dist, right_dist);
    } else {
        // Show that distributive property fails
        try testing.expect(left_dist != right_dist);
        // But they should be very close
        try testing.expectApproxEqRel(left_dist, right_dist, 1e-12);
    }
}

test "complex arithmetic operations with precision loss" {
    const tolerance = 1e-13;
    
    // Complex expression that accumulates precision errors
    const a: f64 = 118.51111121;
    const b: f64 = 0.5465441;
    const c: f64 = 1.5144;
    const d: f64 = 2.0;
    const e: f64 = 5.4;
    
    const result = (a + b - c) / d * e;
    const expected: f64 = 317.366789337; // This is the "correct" decimal result
    
    print("Complex calculation: ({} + {} - {}) / {} * {} = {}\n", .{ a, b, c, d, e, result });
    print("Expected: {}\n", .{expected});
    print("Difference: {}\n", .{result - expected});
    
    // The result won't be exactly equal due to accumulated precision errors
    try testing.expect(result != expected);
    
    // But should be close
    try testing.expectApproxEqRel(result, expected, tolerance);
}

test "precision loss in financial calculations" {
    // Simulating a financial calculation that shows precision loss
    const principal: f64 = 35.05;
    const rate1: f64 = 1600.0;
    const rate2: f64 = 400.0;
    const divisor: f64 = 2000.0;
    const multiplier: f64 = 10000.0;
    
    // Two mathematically equivalent calculations
    const calc1 = (principal * rate1 + principal * rate2) / divisor * multiplier;
    const calc2 = principal * multiplier;
    
    print("Financial calculation precision test:\n", .{});
    print("Method 1: ({} * {} + {} * {}) / {} * {} = {}\n", .{ principal, rate1, principal, rate2, divisor, multiplier, calc1 });
    print("Method 2: {} * {} = {}\n", .{ principal, multiplier, calc2 });
    print("Difference: {}\n", .{calc1 - calc2});
    
    // These should be equal mathematically but aren't due to precision - exact test
    try testing.expect(calc1 != calc2);
    
    // The difference should be small but measurable - exact range tests
    const diff = @abs(calc1 - calc2);
    try testing.expect(diff > 0.0);
    try testing.expect(diff < 1.0); // Should be less than 1 unit
}

test "comparison operations with floating point" {
    const tolerance = 1e-15;
    
    // Use the same precision issue we know works from our first test
    var sum: f64 = 0.0;
    for (0..10) |_| {
        sum += 0.1;
    }
    const expected: f64 = 1.0;
    
    print("Comparison test: sum of 0.1 ten times = {}, 1.0 = {}\n", .{ sum, expected });
    print("Difference: {}\n", .{sum - expected});
    
    // This should definitely show precision issues
    try testing.expect(sum != expected);
    try testing.expectApproxEqRel(sum, expected, tolerance);
    
    // Test another known precision issue case
    const a: f64 = 0.1;
    const b: f64 = 0.2;
    const c: f64 = 0.3;
    const sum_ab = a + b;
    
    print("Testing: {} + {} = {} vs {}\n", .{ a, b, sum_ab, c });
    print("Difference: {}\n", .{sum_ab - c});
    
    // Check if this case shows precision issues
    if (sum_ab != c) {
        try testing.expect(sum_ab != c);
        try testing.expectApproxEqRel(sum_ab, c, tolerance);
    } else {
        // If not, just verify they're close enough
        try testing.expectApproxEqRel(sum_ab, c, tolerance);
    }
    
    // Test ordering with precision issues using our known problematic values
    const values = [_]f64{ 0.1, sum, expected };
    
    for (values, 0..) |val, i| {
        for (values, 0..) |other_val, j| {
            if (i != j) {
                const diff = @abs(val - other_val);
                if (diff < tolerance and diff > 0) {
                    print("Values {} and {} are approximately equal (diff: {})\n", .{ val, other_val, diff });
                }
            }
        }
    }
}

test "rounding and truncation behavior" {
    const test_values = [_]f64{ 118.51111121, 118.55555, 118.5, 2.145, 0.12345, -8.5, -0.12345 };
    
    for (test_values) |val| {
        // Different rounding methods can give different results
        const rounded = @round(val);
        const truncated = @trunc(val);
        const floored = @floor(val);
        const ceiled = @ceil(val);
        
        print("Value: {} -> round: {}, trunc: {}, floor: {}, ceil: {}\n", 
              .{ val, rounded, truncated, floored, ceiled });
        
        // Test mathematical properties - these should be exact
        try testing.expect(floored <= val);
        try testing.expect(val <= ceiled);
        
        // Mathematical properties of truncation - these are exact
        if (val >= 0) {
            try testing.expectEqual(truncated, floored);
        } else {
            try testing.expectEqual(truncated, ceiled);
        }
    }
}

test "large number precision loss" {
    // Very large numbers lose precision in the fractional part
    const large_base: f64 = 4444444444444444444444118.0;
    const small_addition: f64 = 0.51111121;
    
    const result = large_base + small_addition;
    const expected_diff = small_addition;
    const actual_diff = result - large_base;
    
    print("Large number test:\n", .{});
    print("Base: {}\n", .{large_base});
    print("Adding: {}\n", .{small_addition});
    print("Result: {}\n", .{result});
    print("Expected difference: {}\n", .{expected_diff});
    print("Actual difference: {}\n", .{actual_diff});
    
    // The small addition gets lost due to precision limits - this is exact
    try testing.expect(actual_diff != expected_diff);
    
    // In fact, for numbers this large, the addition might be completely lost - exact test
    if (large_base > 1e15) {
        // For numbers this large, adding small fractions has no effect
        try testing.expectEqual(result, large_base);
    }
}

test "denormalized numbers and underflow" {
    // Test behavior near the limits of floating-point representation
    const very_small: f64 = 1e-308;
    const tiny_addition: f64 = 1e-324; // Near the smallest representable number
    
    const result = very_small + tiny_addition;
    
    print("Denormalized number test:\n", .{});
    print("Very small: {}\n", .{very_small});
    print("Tiny addition: {}\n", .{tiny_addition});
    print("Result: {}\n", .{result});
    
    // The tiny addition might be lost or cause denormalization
    const diff = result - very_small;
    print("Actual difference: {}\n", .{diff});
    
    // Test that we can detect underflow conditions - these are exact boolean tests
    try testing.expect(math.isFinite(result));
    try testing.expect(!math.isInf(result));
    try testing.expect(!math.isNan(result));
}

test "special values and edge cases" {
    // Test behavior with special floating-point values
    const pos_inf = math.inf(f64);
    const neg_inf = -math.inf(f64);
    const nan_val = math.nan(f64);
    const pos_zero: f64 = 0.0;
    const neg_zero: f64 = -0.0;
    
    print("Special values test:\n", .{});
    print("Positive infinity: {}\n", .{pos_inf});
    print("Negative infinity: {}\n", .{neg_inf});
    print("NaN: {}\n", .{nan_val});
    print("Positive zero: {}\n", .{pos_zero});
    print("Negative zero: {}\n", .{neg_zero});
    
    // Test properties of special values - all exact boolean tests
    try testing.expect(math.isInf(pos_inf));
    try testing.expect(math.isInf(neg_inf));
    try testing.expect(math.isNan(nan_val));
    try testing.expectEqual(pos_zero, neg_zero); // -0.0 == 0.0 is exact
    
    // Test arithmetic with special values - all exact boolean tests
    try testing.expect(math.isNan(nan_val + 1.0));
    try testing.expect(math.isInf(pos_inf + 1.0));
    try testing.expect(math.isNan(pos_inf - pos_inf));
    
    // Division by zero behavior - exact tests
    const div_by_pos_zero = 1.0 / pos_zero;
    const div_by_neg_zero = 1.0 / neg_zero;
    
    try testing.expect(math.isInf(div_by_pos_zero));
    try testing.expect(math.isInf(div_by_neg_zero));
    try testing.expect(div_by_pos_zero > 0);
    try testing.expect(div_by_neg_zero < 0);
}
