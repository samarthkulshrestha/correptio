const std = @import("std");
const debuginfo = @import("debuginfo.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();
    // FIXME: hardcoded path
    const dump = try debuginfo.DebugDump.init(alloc, "./zig-out/bin/debuggee");
    defer {
        for (dump) |*die| {
            die.deinit(alloc);
        }
        alloc.free(dump);
    }
    const output_f = try std.fs.cwd().createFile("output.json", .{});
    defer output_f.close();
    var output_buffered = std.io.bufferedWriter(output_f.writer());
    defer output_buffered.flush() catch {};
    try std.json.stringify(dump, .{ .whitespace = .indent_2 }, output_buffered.writer());
}
