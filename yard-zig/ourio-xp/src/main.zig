const std = @import("std");
const io = @import("ourio");
const posix = std.posix;
const Allocator = std.mem.Allocator;

pub const MultiWriter = struct {
    fd1: posix.fd_t,
    fd1_written: usize = 0,

    fd2: posix.fd_t,
    fd2_written: usize = 0,

    buf: std.ArrayListUnmanaged(u8) = .empty,

    pub const Msg = enum { fd1, fd2 };

    pub fn init(fd1: posix.fd_t, fd2: posix.fd_t) MultiWriter {
        return .{ .fd1 = fd1, .fd2 = fd2 };
    }

    pub fn write(self: *MultiWriter, gpa: Allocator, bytes: []const u8) !void {
        try self.buf.appendSlice(gpa, bytes);
    }

    pub fn flush(self: *MultiWriter, rt: *io.Ring) !void {
        if (self.fd1_written < self.buf.items.len) {
            _ = try rt.write(self.fd1, self.buf.items[self.fd1_written..], .{
                .ptr = self,
                .msg = @intFromEnum(Msg.fd1),
                .cb = MultiWriter.onCompletion,
            });
        }

        if (self.fd2_written < self.buf.items.len) {
            _ = try rt.write(self.fd2, self.buf.items[self.fd2_written..], .{
                .ptr = self,
                .msg = @intFromEnum(Msg.fd2),
                .cb = MultiWriter.onCompletion,
            });
        }
    }

    pub fn onCompletion(rt: *io.Ring, task: io.Task) anyerror!void {
        const self = task.userdataCast(MultiWriter);
        const result = task.result.?;

        const n = try result.write;
        switch (task.msgToEnum(MultiWriter.Msg)) {
            .fd1 => self.fd1_written += n,
            .fd2 => self.fd2_written += n,
        }

        const len = self.buf.items.len;

        if (self.fd1_written < len or self.fd2_written < len) 
	    return self.flush(rt);

        self.fd1_written = 0;
        self.fd2_written = 0;
        self.buf.clearRetainingCapacity();
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    var rt: io.Ring = try .init(gpa.allocator(), 16);
    defer rt.deinit();

    // Pretend I created some files
    const fd1: posix.fd_t = 5;
    const fd2: posix.fd_t = 6;

    var mw: MultiWriter = .init(fd1, fd2);
    try mw.write(gpa.allocator(), "Hello, world!");
    try mw.flush(&rt);

    try rt.run(.until_done);
}
