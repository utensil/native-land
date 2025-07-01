const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

// Basic string literal tests
test "basic string literals" {
    const simple = "Hello, World!";
    try expect(eql(u8, simple, "Hello, World!"));
    try expect(simple.len == 13);
}

test "string literal with escape sequences" {
    const with_escapes = "Line 1\nLine 2\tTabbed\r\nWindows line ending";
    try expect(with_escapes[6] == '\n');
    try expect(with_escapes[13] == '\t');
}

test "raw string literals" {
    const raw = 
        \\This is a raw string
        \\with multiple lines
        \\and \n escape sequences are literal
    ;
    
    try expect(eql(u8, raw, "This is a raw string\nwith multiple lines\nand \\n escape sequences are literal"));
    try expect(raw.len == 76);
}

// Multiline string literal tests
test "multiline string literals - basic" {
    const multiline = 
        \\First line
        \\Second line
        \\Third line
    ;
    
    const expected = "First line\nSecond line\nThird line";
    try expect(eql(u8, multiline, expected));
    try expect(multiline.len == 33);
}

test "multiline string literals - with indentation" {
    const indented = 
        \\    Indented first line
        \\    Indented second line
        \\        More indented line
    ;
    
    const expected = "    Indented first line\n    Indented second line\n        More indented line";
    try expect(eql(u8, indented, expected));
}

test "multiline string literals - empty lines" {
    const with_empty = 
        \\First line
        \\
        \\Third line after empty
        \\
    ;
    
    const expected = "First line\n\nThird line after empty\n";
    try expect(eql(u8, with_empty, expected));
    try expect(with_empty.len == 35);
}

test "multiline string literals - single line" {
    const single = 
        \\Just one line
    ;
    
    try expect(eql(u8, single, "Just one line"));
    try expect(single.len == 13);
}

test "multiline string literals - special characters" {
    const special = 
        \\Line with "quotes" and 'apostrophes'
        \\Line with backslashes: \ \\ \\\
        \\Line with unicode: 🦎 ∑ ∞
    ;
    
    try expect(std.mem.indexOf(u8, special, "quotes").? > 0);
    try expect(std.mem.indexOf(u8, special, "\\\\").? > 0);
    try expect(std.mem.indexOf(u8, special, "🦎").? > 0);
}

test "multiline string literals - code-like content" {
    const code_block = 
        \\fn main() void {
        \\    const x = 42;
        \\    if (x > 0) {
        \\        print("positive");
        \\    }
        \\}
    ;
    
    try expect(std.mem.indexOf(u8, code_block, "fn main()").? == 0);
    try expect(std.mem.indexOf(u8, code_block, "const x = 42").? > 0);
    try expect(std.mem.count(u8, code_block, "\n") == 5);
}

test "multiline string literals - mixed with regular strings" {
    const regular = "Regular string";
    const multiline = 
        \\Multiline
        \\string
    ;
    
    try expect(eql(u8, regular, "Regular string"));
    try expect(eql(u8, multiline, "Multiline\nstring"));
    
    // Concatenation at compile time
    const combined = regular ++ "\n" ++ multiline;
    try expect(eql(u8, combined, "Regular string\nMultiline\nstring"));
}

test "multiline string literals - trailing whitespace handling" {
    // Zig multiline strings preserve trailing spaces on each line
    const with_trailing_spaces = 
        \\Line with trailing spaces   
        \\Another line    
        \\Final line
    ;
    
    // Check that trailing spaces are preserved
    var lines = std.mem.splitSequence(u8, with_trailing_spaces, "\n");
    const first_line = lines.next().?;
    try expect(first_line.len == 28); // "Line with trailing spaces   " = 28 chars
    try expect(first_line[first_line.len - 1] == ' ');
}

test "multiline string literals - very long content" {
    const long_multiline = 
        \\This is a very long multiline string that demonstrates
        \\how Zig handles multiline string literals with many lines
        \\and various types of content including numbers 123456789
        \\and special characters !@#$%^&*()_+-=[]{}|;:,.<>?
        \\Lorem ipsum dolor sit amet, consectetur adipiscing elit
        \\sed do eiusmod tempor incididunt ut labore et dolore magna
        \\aliqua. Ut enim ad minim veniam, quis nostrud exercitation
        \\ullamco laboris nisi ut aliquip ex ea commodo consequat.
    ;
    
    try expect(long_multiline.len > 400);
    try expect(std.mem.count(u8, long_multiline, "\n") == 7);
    try expect(std.mem.indexOf(u8, long_multiline, "Lorem ipsum").? > 0);
}

test "multiline string literals - comparison with regular multiline" {
    // Regular multiline string (with explicit \n)
    const regular_multiline = "Line 1\nLine 2\nLine 3";
    
    // Multiline string literal
    const literal_multiline = 
        \\Line 1
        \\Line 2
        \\Line 3
    ;
    
    // They should be equivalent
    try expect(eql(u8, regular_multiline, literal_multiline));
    try expect(regular_multiline.len == literal_multiline.len);
}
