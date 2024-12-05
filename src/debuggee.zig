const std = @import("std");

fn do_print_loop(val: usize) void {
    std.debug.print("loop iter {d}\n", .{val});
}

fn do_print_loop_2(val: usize) void {
    std.debug.print("another loop iter {d}\n", .{val});
}

pub fn main() !void {
    std.debug.print("hi!\n", .{});

    for (0..5) |i| {
        do_print_loop(i);
        do_print_loop_2(i);
    }

    std.debug.print("bye!\n", .{});
}
