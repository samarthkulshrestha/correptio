const std = @import("std");
const Allocator = std.mem.Allocator;
const c = @cImport({
    @cInclude("sys/user.h");
});

// pub fn set_bp()

fn print_pid_maps(alloc: Allocator, pid: std.os.linux.pid_t) void {
    var path_buf: [1024]u8 = undefined;
    const maps_path = try std.fmt.bufPrint(&path_buf, "/proc/{d}/maps", .{pid});
    const f = try std.fs.openFileAbsolute(maps_path, .{});
    defer f.close();

    const maps_data = try f.readToEndAlloc(alloc, 1e9);
    defer alloc.free(maps_data);

    std.debug.print("current maps:\n{s}\n", .{maps_data});
}

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    //
    // const alloc = gpa.allocator();

    const pid = try std.posix.fork();
    if (pid == 0) {
        try std.posix.ptrace(std.os.linux.PTRACE.TRACEME, 0, undefined, undefined);
        std.posix.execveZ("./zig-out/bin/debuggee", &.{null}, &.{null}) catch {
            std.log.err("exec error.", .{});
        };
    } else {
        while (true) {
            const ret = std.posix.waitpid(pid, 0);
            std.debug.print("received ret\n", .{});
            if (std.os.linux.W.IFSIGNALED(ret.status)) {
                std.debug.print("child signalled.\n", .{});
                break;
            }
            if (!std.os.linux.W.IFSTOPPED(ret.status)) {
                std.debug.print("{any}\n", .{ret});
                break;
            }

            var user_data: c.user = undefined;
            try std.posix.ptrace(std.os.linux.PTRACE.GETREGS, pid, 0, @intFromPtr(&user_data));

            const start_addr = 0x1034a20;
            if (user_data.regs.rip == start_addr) {
                const bp_addr = 0x10352e0;
                var current_data: u64 = 0;
                try std.posix.ptrace(std.os.linux.PTRACE.PEEKTEXT, pid, bp_addr, @intFromPtr(&current_data));
                current_data = ~@as(u64, 0xff) | 0xcc;
                try std.posix.ptrace(std.os.linux.PTRACE.POKETEXT, pid, bp_addr, @intFromPtr(&current_data));
                try std.posix.ptrace(std.os.linux.PTRACE.CONT, pid, 0, undefined);

            } else {
                std.debug.print("program counter at: {x}\n", .{user_data.regs.rip});
                var siginfo: std.os.linux.siginfo_t = undefined;
                try std.posix.ptrace(std.os.linux.PTRACE.GETSIGINFO, pid, 0, @intFromPtr(&siginfo));
                std.debug.print("sleeping for 1e9 nanosecs.\n", .{});
                std.time.sleep(1e9);
                std.debug.print("waking up.\n", .{});
                try std.posix.ptrace(std.os.linux.PTRACE.CONT, pid, @intCast(siginfo.signo), undefined);
            }
        }
        std.debug.print("exiting parent.\n", .{});
        return;
    }
}
