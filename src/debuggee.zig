const std = @import("std");

fn eat(_: anytype) void {}

const GlobalVarTracker = enum(u54) {
    a,
    b,
    c,
};
var my_global_var_pog: usize = 4;
var my_global_var_2: GlobalVarTracker = .a;

fn do_print_loop(val: usize) void {
    const x: i32 = 4 + @as(i32, @intCast(val));
    const y: u8 = 5 + @as(u8, @intCast(val));
    my_global_var_pog += 1;
    eat(x);
    eat(y);
    // disabling for demonstration purposes,
    // the dubugger tries to step into zig's
    // `debug` and we get a permission error
    // as it tries to print `stderr`
    // std.debug.print("loop iter {d} {d} {d} {d} {any}\n", .{ x, y, val, my_global_var_pog, my_global_var_2 });
}

fn do_print_loop_2(val: usize) void {
    // std.debug.print("another loop iter {d}\n", .{val});
    eat(val);
}

pub fn main() !void {
    std.debug.print("hi!\n", .{});

    for (0..5) |i| {
        do_print_loop(i);
        do_print_loop_2(i);
    }

    std.debug.print("bye!\n", .{});
}
