const std = @import("std");

fn do_print_loop(val: usize) void {
    std.debug.print("loop iter {d}\n", .{val});
}

pub fn main() !void {
    std.debug.print("hi!\n", .{});
    std.debug.print("address of do_print_loop(): 0x{x}\n", .{&do_print_loop});

    for (0..5) |i| {
        do_print_loop(i);
    }

    std.debug.print("bye!\n", .{});
}
