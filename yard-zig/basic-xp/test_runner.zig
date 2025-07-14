// The following code is adapted from https://gist.github.com/nurpax/4afcb6e4ef3f03f0d282f7c462005f12

// Modded from from https://gist.github.com/karlseguin/c6bea5b35e4e8d26af6f81c22cb5d76b

// in your build.zig, you can specify a custom test runner:
// const tests = b.addTest(.{
//   .target = target,
//   .optimize = optimize,
//   .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple }, // add this line
//   .root_source_file = b.path("src/main.zig"),
// });

const std = @import("std");
const builtin = @import("builtin");

const BORDER = "=" ** 80;

const Status = enum {
    pass,
    fail,
    skip,
    text,
};

fn getTestFileName(name: []const u8) []const u8 {
    if (std.mem.indexOfScalar(u8, name, '.')) |dot_pos| {
        return name[0..dot_pos];
    }
    return name;
}

fn getenvOwned(alloc: std.mem.Allocator, key: []const u8) ?[]u8 {
    const v = std.process.getEnvVarOwned(alloc, key) catch |err| {
        if (err == error.EnvironmentVariableNotFound) {
            return null;
        }
        std.log.warn("failed to get env var {s} due to err {}", .{ key, err });
        return null;
    };
    return v;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};
    const alloc = gpa.allocator();
    const fail_first = blk: {
        if (getenvOwned(alloc, "TEST_FAIL_FIRST")) |e| {
            defer alloc.free(e);
            break :blk std.mem.eql(u8, e, "true");
        }
        break :blk false;
    };
    const filter = getenvOwned(alloc, "TEST_FILTER");
    defer if (filter) |f| alloc.free(f);

    const printer = Printer.init();
    printer.fmt("\x1b[0K", .{}); // beginning of line and clear to end of line

    var total_pass: usize = 0;
    var total_fail: usize = 0;
    var total_skip: usize = 0;
    var total_leak: usize = 0;
    
    var current_file: []const u8 = "";
    var file_pass: usize = 0;
    var file_fail: usize = 0;
    var file_skip: usize = 0;
    var file_leak: usize = 0;

    for (builtin.test_functions) |t| {
        std.testing.allocator_instance = .{};
        var status = Status.pass;

        if (filter) |f| {
            if (std.mem.indexOf(u8, t.name, f) == null) {
                continue;
            }
        }

        const test_file = getTestFileName(t.name);
        if (!std.mem.eql(u8, current_file, test_file)) {
            // Report previous file's results if we have any
            if (current_file.len > 0) {
                const file_total = file_pass + file_fail;
                if (file_total > 0) {
                    const file_status: Status = if (file_fail == 0) .pass else .fail;
                    printer.status(file_status, "{s}: {d} of {d} test{s} passed", .{ current_file, file_pass, file_total, if (file_total != 1) "s" else "" });
                    if (file_skip > 0) {
                        printer.status(.skip, ", {d} skipped", .{file_skip});
                    }
                    if (file_leak > 0) {
                        printer.status(.fail, ", {d} leaked", .{file_leak});
                    }
                    printer.fmt("\n", .{});
                }
            }
            
            // Reset counters for new file
            current_file = test_file;
            file_pass = 0;
            file_fail = 0;
            file_skip = 0;
            file_leak = 0;
        }

        printer.fmt("{s} ", .{t.name});
        const result = t.func();

        if (std.testing.allocator_instance.deinit() == .leak) {
            file_leak += 1;
            total_leak += 1;
            printer.status(.fail, "\n{s}\n\"{s}\" - Memory Leak\n{s}\n", .{ BORDER, t.name, BORDER });
        }

        if (result) |_| {
            file_pass += 1;
            total_pass += 1;
        } else |err| {
            switch (err) {
                error.SkipZigTest => {
                    file_skip += 1;
                    total_skip += 1;
                    status = .skip;
                },
                else => {
                    status = .fail;
                    file_fail += 1;
                    total_fail += 1;
                    printer.status(.fail, "\n{s}\n\"{s}\" - {s}\n{s}\n", .{ BORDER, t.name, @errorName(err), BORDER });
                    if (@errorReturnTrace()) |trace| {
                        std.debug.dumpStackTrace(trace.*);
                    }
                    if (fail_first) {
                        break;
                    }
                },
            }
        }

        printer.status(status, "[{s}]\n", .{@tagName(status)});
    }

    // Report the last file's results
    if (current_file.len > 0) {
        const file_total = file_pass + file_fail;
        if (file_total > 0) {
            const file_status: Status = if (file_fail == 0) .pass else .fail;
            printer.status(file_status, "{s}: {d} of {d} test{s} passed", .{ current_file, file_pass, file_total, if (file_total != 1) "s" else "" });
            if (file_skip > 0) {
                printer.status(.skip, ", {d} skipped", .{file_skip});
            }
            if (file_leak > 0) {
                printer.status(.fail, ", {d} leaked", .{file_leak});
            }
            printer.fmt("\n", .{});
        }
    }

    const total_tests = total_pass + total_fail;
    const status: Status = if (total_fail == 0) .pass else .fail;

    // there might be no test matching the filter
    if (total_tests == 0) {
        std.process.exit(0);
    }

    // Overall summary
    printer.status(status, "Total: {d} of {d} test{s} passed\n", .{ total_pass, total_tests, if (total_tests != 1) "s" else "" });
    if (total_skip > 0) {
        printer.status(.skip, "Total: {d} test{s} skipped\n", .{ total_skip, if (total_skip != 1) "s" else "" });
    }
    if (total_leak > 0) {
        printer.status(.fail, "Total: {d} test{s} leaked\n", .{ total_leak, if (total_leak != 1) "s" else "" });
    }
    std.process.exit(if (total_fail == 0) 0 else 1);
}

const Printer = struct {
    fn init() Printer {
        return .{};
    }

    fn fmt(self: Printer, comptime format: []const u8, args: anytype) void {
        _ = self;
        std.debug.print(format, args);
    }

    fn status(self: Printer, s: Status, comptime format: []const u8, args: anytype) void {
        const color = switch (s) {
            .pass => "\x1b[32m",
            .fail => "\x1b[31m",
            .skip => "\x1b[33m",
            else => "",
        };
        std.debug.print("{s}", .{color});
        std.debug.print(format, args);
        self.fmt("\x1b[0m", .{});
    }
};
