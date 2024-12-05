const std = @import("std");

fn do_bye() void {
    std.debug.print("bye!\n", .{});
}

pub fn main() !void {
    std.debug.print("hi!\n", .{});
    std.debug.print("address of do_bye(): 0x{x}\n", .{&do_bye});
    const content: [*]const u8 = @ptrCast(&do_bye);
    std.debug.print("content of do_bye(): {x}\n", .{std.mem.bytesAsValue(u32, content[0..4]).*});
    do_bye();
}
