const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

// Core multiline string literal functionality
test "multiline string literals vs regular strings" {
    // Regular string with explicit \n
    const regular = "Line 1\nLine 2\nLine 3";
    
    // Multiline string literal - equivalent but more readable
    const multiline = 
        \\Line 1
        \\Line 2
        \\Line 3
    ;
    
    try expect(eql(u8, regular, multiline));
}

// The key advantage: escape sequences are literal
test "multiline strings preserve backslashes" {
    const code_template = 
        \\const pattern = "\\d+";
        \\const path = "C:\\Users\\name";
        \\const regex = /\w+\.\w+/;
    ;
    
    // No need to double-escape backslashes like in regular strings
    try expect(std.mem.indexOf(u8, code_template, "\\\\d+").? > 0);
    try expect(std.mem.indexOf(u8, code_template, "C:\\\\Users").? > 0);
    try expect(std.mem.indexOf(u8, code_template, "/\\w+\\.\\w+/").? > 0);
}

// Practical use case: embedded code or templates
test "multiline strings for code generation" {
    const json_template = 
        \\{
        \\  "name": "example",
        \\  "version": "1.0.0",
        \\  "dependencies": {}
        \\}
    ;
    
    try expect(std.mem.count(u8, json_template, "\n") == 4);
    try expect(std.mem.indexOf(u8, json_template, "\"name\"").? > 0);
}

// Edge case: trailing whitespace is preserved
test "multiline strings preserve trailing whitespace" {
    const with_spaces = 
        \\Line with spaces   
        \\Another line
    ;
    
    var lines = std.mem.splitSequence(u8, with_spaces, "\n");
    const first_line = lines.next().?;
    try expect(first_line[first_line.len - 1] == ' ');
}
