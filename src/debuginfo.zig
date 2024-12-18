const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");
const elf = @import("elf.zig");
const libdwarf = @cImport({
    @cInclude("dwarf.h");
    @cInclude("libdwarf.h");
});

fn tagString(tag: libdwarf.Dwarf_Half) []const u8 {
    return switch (tag) {
        0x01 => "DW_TAG_array_type",
        0x02 => "DW_TAG_class_type",
        0x03 => "DW_TAG_entry_point",
        0x04 => "DW_TAG_enumeration_type",
        0x05 => "DW_TAG_formal_parameter",
        0x08 => "DW_TAG_imported_declaration",
        0x0a => "DW_TAG_label",
        0x0b => "DW_TAG_lexical_block",
        0x0d => "DW_TAG_member",
        0x0f => "DW_TAG_pointer_type",
        0x10 => "DW_TAG_reference_type",
        0x11 => "DW_TAG_compile_unit",
        0x12 => "DW_TAG_string_type",
        0x13 => "DW_TAG_structure_type",
        0x15 => "DW_TAG_subroutine_type",
        0x16 => "DW_TAG_typedef",
        0x17 => "DW_TAG_union_type",
        0x18 => "DW_TAG_unspecified_parameters",
        0x19 => "DW_TAG_variant",
        0x1a => "DW_TAG_common_block",
        0x1b => "DW_TAG_common_inclusion",
        0x1c => "DW_TAG_inheritance",
        0x1d => "DW_TAG_inlined_subroutine",
        0x1e => "DW_TAG_module",
        0x1f => "DW_TAG_ptr_to_member_type",
        0x20 => "DW_TAG_set_type",
        0x21 => "DW_TAG_subrange_type",
        0x22 => "DW_TAG_with_stmt",
        0x23 => "DW_TAG_access_declaration",
        0x24 => "DW_TAG_base_type",
        0x25 => "DW_TAG_catch_block",
        0x26 => "DW_TAG_const_type",
        0x27 => "DW_TAG_constant",
        0x28 => "DW_TAG_enumerator",
        0x29 => "DW_TAG_file_type",
        0x2a => "DW_TAG_friend",
        0x2b => "DW_TAG_namelist",
        0x2c => "DW_TAG_namelist_item",
        0x2d => "DW_TAG_packed_type",
        0x2e => "DW_TAG_subprogram",
        0x2f => "DW_TAG_template_type_parameter",
        0x30 => "DW_TAG_template_value_parameter",
        0x31 => "DW_TAG_thrown_type",
        0x32 => "DW_TAG_try_block",
        0x33 => "DW_TAG_variant_part",
        0x34 => "DW_TAG_variable",
        0x35 => "DW_TAG_volatile_type",
        0x36 => "DW_TAG_dwarf_procedure",
        0x37 => "DW_TAG_restrict_type",
        0x38 => "DW_TAG_interface_type",
        0x39 => "DW_TAG_namespace",
        0x3a => "DW_TAG_imported_module",
        0x3b => "DW_TAG_unspecified_type",
        0x3c => "DW_TAG_partial_unit",
        0x3d => "DW_TAG_imported_unit",
        0x3e => "DW_TAG_mutable_type",
        0x3f => "DW_TAG_condition",
        0x40 => "DW_TAG_shared_type",
        0x41 => "DW_TAG_type_unit",
        0x42 => "DW_TAG_rvalue_reference_type",
        0x43 => "DW_TAG_template_alias",
        0x44 => "DW_TAG_coarray_type",
        0x45 => "DW_TAG_generic_subrange",
        0x46 => "DW_TAG_dynamic_type",
        0x47 => "DW_TAG_atomic_type",
        0x48 => "DW_TAG_call_site",
        0x49 => "DW_TAG_call_site_parameter",
        0x4a => "DW_TAG_skeleton_unit",
        0x4b => "DW_TAG_immutable_type",
        0x4080 => "DW_TAG_lo_user/DW_TAG_TI_far_type",
        0x4081 => "DW_TAG_MIPS_loop/DW_TAG_TI_near_type",
        0x4082 => "DW_TAG_TI_assign_register",
        0x4083 => "DW_TAG_TI_ioport_type",
        0x4084 => "DW_TAG_TI_restrict_type",
        0x4085 => "DW_TAG_TI_onchip_type",
        0x4090 => "DW_TAG_HP_array_descriptor",
        0x4101 => "DW_TAG_format_label",
        0x4102 => "DW_TAG_function_template",
        0x4103 => "DW_TAG_class_template",
        0x4104 => "DW_TAG_GNU_BINCL",
        0x4105 => "DW_TAG_GNU_EINCL",
        0x4106 => "DW_TAG_GNU_template_template_parameter",
        0x4107 => "DW_TAG_GNU_template_parameter_pack",
        0x4108 => "DW_TAG_GNU_formal_parameter_pack",
        0x4109 => "DW_TAG_GNU_call_site",
        0x410a => "DW_TAG_GNU_call_site_parameter",
        0x4201 => "DW_TAG_SUN_function_template",
        0x4202 => "DW_TAG_SUN_class_template",
        0x4203 => "DW_TAG_SUN_struct_template",
        0x4204 => "DW_TAG_SUN_union_template",
        0x4205 => "DW_TAG_SUN_indirect_inheritance",
        0x4206 => "DW_TAG_SUN_codeflags",
        0x4207 => "DW_TAG_SUN_memop_info",
        0x4208 => "DW_TAG_SUN_omp_child_func",
        0x4209 => "DW_TAG_SUN_rtti_descriptor",
        0x420a => "DW_TAG_SUN_dtor_info",
        0x420b => "DW_TAG_SUN_dtor",
        0x420c => "DW_TAG_SUN_f90_interface",
        0x420d => "DW_TAG_SUN_fortran_vax_structure",
        0x42ff => "DW_TAG_SUN_hi",
        0x5101 => "DW_TAG_ALTIUM_circ_type",
        0x5102 => "DW_TAG_ALTIUM_mwa_circ_type",
        0x5103 => "DW_TAG_ALTIUM_rev_carry_type",
        0x5111 => "DW_TAG_ALTIUM_rom",
        0x6000 => "DW_TAG_LLVM_annotation",
        0x8004 => "DW_TAG_ghs_namespace",
        0x8005 => "DW_TAG_ghs_using_namespace",
        0x8006 => "DW_TAG_ghs_using_declaration",
        0x8007 => "DW_TAG_ghs_template_templ_param",
        0x8765 => "DW_TAG_upc_shared_type",
        0x8766 => "DW_TAG_upc_strict_type",
        0x8767 => "DW_TAG_upc_relaxed_type",
        0xa000 => "DW_TAG_PGI_kanji_type",
        0xa020 => "DW_TAG_PGI_interface_block",
        0xb000 => "DW_TAG_BORLAND_property",
        0xb001 => "DW_TAG_BORLAND_Delphi_string",
        0xb002 => "DW_TAG_BORLAND_Delphi_dynamic_array",
        0xb003 => "DW_TAG_BORLAND_Delphi_set",
        0xb004 => "DW_TAG_BORLAND_Delphi_variant",
        0xffff => "DW_TAG_hi_user",
        else => "unknown",
    };
}

const DwarfAttr = struct {
    inner: libdwarf.Dwarf_Attribute,

    fn deinit(self: *DwarfAttr) void {
        libdwarf.dwarf_dealloc_attribute(self.inner);
    }

    fn asAddr(self: *const DwarfAttr) !u64 {
        var ret: libdwarf.Dwarf_Addr = undefined;
        const err = libdwarf.dwarf_formaddr(self.inner, &ret, null);

        if (err != libdwarf.DW_DLV_OK) {
            return error.NotAddr;
        }

        return ret;
    }

    fn asU64(self: *const DwarfAttr) !u64 {
        var ret: libdwarf.Dwarf_Unsigned = undefined;
        const err = libdwarf.dwarf_formudata(self.inner, &ret, null);

        if (err != libdwarf.DW_DLV_OK) {
            return error.NotU64;
        }

        return ret;
    }

    fn asGlobalOffs(self: *const DwarfAttr) !u64 {
        var ret: libdwarf.Dwarf_Addr = undefined;
        var is_info: c_int = undefined;

        const err = libdwarf.dwarf_global_formref_b(self.inner, &ret, &is_info, null);
        if (err != libdwarf.DW_DLV_OK) {
            return error.NotAddr;
        }

        return ret;
    }

    fn asString(self: *const DwarfAttr) ![]const u8 {
        var s: [*c]u8 = undefined;
        const err = libdwarf.dwarf_formstring(self.inner, &s, null);

        if (err != libdwarf.DW_DLV_OK) {
            return error.NotString;
        }
        return std.mem.span(s);
    }

    fn form(self: *const DwarfAttr) !u32 {
        var ret: libdwarf.Dwarf_Half = undefined;
        const err = libdwarf.dwarf_whatform(self.inner, &ret, null);

        if (err != libdwarf.DW_DLV_OK) {
            return error.UnknownForm;
        }
        return ret;
    }

    fn asDie(self: *const DwarfAttr, dbg: libdwarf.Dwarf_Debug) !DwarfDie {
        var offs: libdwarf.Dwarf_Off = undefined;
        var is_info: c_int = 0;
        var err = libdwarf.dwarf_formref(self.inner, &offs, &is_info, null);

        if (err != libdwarf.DW_DLV_OK) {
            return error.NotOffs;
        }

        var global_offs: libdwarf.Dwarf_Off = undefined;
        err = libdwarf.dwarf_convert_to_global_offset(self.inner, offs, &global_offs, null);
        if (err != libdwarf.DW_DLV_OK) {
            return error.InvalidOffset;
        }

        var die: libdwarf.Dwarf_Die = undefined;
        err = libdwarf.dwarf_offdie_b(dbg, global_offs, is_info, &die, null);
        if (err != libdwarf.DW_DLV_OK) {
            return error.InvalidGlobalOffset;
        }

        return .{
            .die = die,
        };
    }
};

pub const Local = struct {
    name: []const u8,
    type_name: []const u8,
    type_size: ?u8,
    op: DwOp,
};

pub const DwarfDie = struct {
    die: libdwarf.Dwarf_Die,

    pub fn deinit(self: *const DwarfDie) void {
        libdwarf.dwarf_dealloc_die(self.die);
    }

    // NOTE: Tied to lifetime of die
    pub fn name(self: *const DwarfDie) ![]const u8 {
        var name_attr = try self.attr(libdwarf.DW_AT_name);
        defer name_attr.deinit();

        return name_attr.asString();
    }

    pub fn getLocals(self: *const DwarfDie, alloc: Allocator, info: *const DwarfInfo) ![]Local {
        var it = (try self.child()) orelse return &.{};
        errdefer it.deinit();

        var out = std.ArrayList(Local).init(alloc);
        defer out.deinit();

        while (true) {
            const child_tag = try it.tag();
            if (child_tag == libdwarf.DW_TAG_variable) {
                var typ_attr = try it.attr(libdwarf.DW_AT_type);
                defer typ_attr.deinit();
                const typ = try typ_attr.asDie(info.dbg);

                var local = Local{
                    .name = try it.name(),
                    .type_name = try typ.name(),
                    .type_size = null,
                    .op = try DwOp.init(it),
                };
                switch (try typ.tag()) {
                    libdwarf.DW_TAG_base_type => {
                        var size_attr = try typ.attr(libdwarf.DW_AT_byte_size);
                        defer size_attr.deinit();
                        local.type_size = @truncate(try size_attr.asU64());
                    },
                    else => {},
                }

                try out.append(local);
            }

            const next_it = try it.nextSibling();
            it.deinit();
            if (next_it) |val| {
                it = val;
            } else {
                break;
            }
        }

        return try out.toOwnedSlice();
    }

    fn tag(self: *const DwarfDie) !libdwarf.Dwarf_Half {
        var val: libdwarf.Dwarf_Half = 0;
        const ret = libdwarf.dwarf_tag(self.die, &val, null);
        if (ret != libdwarf.DW_DLV_OK) {
            return error.DwarfTag;
        }

        return val;
    }

    fn attr(self: *const DwarfDie, val: u16) !DwarfAttr {
        var output: libdwarf.Dwarf_Attribute = undefined;
        const ret = libdwarf.dwarf_attr(self.die, val, &output, null);
        if (ret != libdwarf.DW_DLV_OK) {
            return error.NoAttr;
        }

        return .{
            .inner = output,
        };
    }

    fn nextSibling(self: *const DwarfDie) !?DwarfDie {
        var new_die: libdwarf.Dwarf_Die = undefined;
        const ret = libdwarf.dwarf_siblingof_c(self.die, &new_die, null);

        if (ret == libdwarf.DW_DLV_NO_ENTRY) {
            return null;
        }

        if (ret != libdwarf.DW_DLV_OK) {
            return error.DwarfDieIter;
        }

        return .{
            .die = new_die,
        };
    }

    fn child(self: *const DwarfDie) !?DwarfDie {
        var new_die: libdwarf.Dwarf_Die = undefined;
        const ret = libdwarf.dwarf_child(self.die, &new_die, null);

        if (ret == libdwarf.DW_DLV_NO_ENTRY) {
            return null;
        }

        if (ret != libdwarf.DW_DLV_OK) {
            return error.DwarfDieIter;
        }

        return .{
            .die = new_die,
        };
    }
};

const CompilationUnitIt = struct {
    dbg: *libdwarf.Dwarf_Debug,

    fn init(dbg: *libdwarf.Dwarf_Debug) !CompilationUnitIt {
        return .{
            .dbg = dbg,
        };
    }

    fn next(self: *CompilationUnitIt) !?DwarfDie {
        var die: libdwarf.Dwarf_Die = undefined;

        const ret = libdwarf.dwarf_next_cu_header_e(
            self.dbg.*,
            1,
            &die,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
        );

        if (ret == libdwarf.DW_DLV_NO_ENTRY) {
            return null;
        }

        if (ret != libdwarf.DW_DLV_OK) {
            return error.DwarfDieIter;
        }

        return .{
            .die = die,
        };
    }
};

pub const DwOp = union(enum) {
    fbreg: i64,
    unknown: struct {
        op: u8,
        opd1: c_ulonglong,
        opd2: c_ulonglong,
        opd3: c_ulonglong,
    },
    none,

    fn init(die: DwarfDie) !DwOp {
        var attr: libdwarf.Dwarf_Attribute = undefined;
        var ret = libdwarf.dwarf_attr(die.die, libdwarf.DW_AT_location, &attr, null);
        if (ret != libdwarf.DW_DLV_OK) {
            return .none;
        }
        defer libdwarf.dwarf_dealloc_attribute(attr);

        var head: libdwarf.Dwarf_Loc_Head_c = undefined;
        var count: libdwarf.Dwarf_Unsigned = undefined;

        ret = libdwarf.dwarf_get_loclist_c(attr, &head, &count, null);
        if (ret != libdwarf.DW_DLV_OK) {
            return error.InvalidLocList;
        }
        defer libdwarf.dwarf_dealloc_loc_head_c(head);

        var desc: libdwarf.Dwarf_Locdesc_c = undefined;
        var dw_lle_value_out: libdwarf.Dwarf_Small = undefined;
        var dw_rawlowpc: libdwarf.Dwarf_Unsigned = undefined;
        var dw_rawhipc: libdwarf.Dwarf_Unsigned = undefined;
        var dw_debug_addr_unavailable: libdwarf.Dwarf_Bool = undefined;
        var dw_lowpc_cooked: libdwarf.Dwarf_Addr = undefined;
        var dw_hipc_cooked: libdwarf.Dwarf_Addr = undefined;
        var dw_locexpr_op_count_out: libdwarf.Dwarf_Unsigned = undefined;
        var dw_loclist_source_out: libdwarf.Dwarf_Small = undefined;
        var dw_expression_offset_out: libdwarf.Dwarf_Unsigned = undefined;
        var dw_locdesc_offset_out: libdwarf.Dwarf_Unsigned = undefined;

        ret = libdwarf.dwarf_get_locdesc_entry_d(
            head,
            0,
            &dw_lle_value_out,
            &dw_rawlowpc,
            &dw_rawhipc,
            &dw_debug_addr_unavailable,
            &dw_lowpc_cooked,
            &dw_hipc_cooked,
            &dw_locexpr_op_count_out,
            &desc,
            &dw_loclist_source_out,
            &dw_expression_offset_out,
            &dw_locdesc_offset_out,
            null,
        );

        if (ret != libdwarf.DW_DLV_OK) {
            return error.InvalidLocDescEntry;
        }

        if (dw_locexpr_op_count_out == 0) {
            // FIXME: Unsure if nonoe makes sense here
            return .none;
        }

        var dw_operator_out: libdwarf.Dwarf_Small = undefined;
        var dw_operand1: libdwarf.Dwarf_Unsigned = undefined;
        var dw_operand2: libdwarf.Dwarf_Unsigned = undefined;
        var dw_operand3: libdwarf.Dwarf_Unsigned = undefined;
        var dw_offset_for_branch: libdwarf.Dwarf_Unsigned = undefined;

        if (dw_locexpr_op_count_out == 0) {
            // FIXME: Unsure if nonoe makes sense here
            return .none;
        }

        ret = libdwarf.dwarf_get_location_op_value_c(desc, 0, &dw_operator_out, &dw_operand1, &dw_operand2, &dw_operand3, &dw_offset_for_branch, null);

        if (ret != libdwarf.DW_DLV_OK) {
            return error.InvalidOp;
        }

        switch (dw_operator_out) {
            libdwarf.DW_OP_fbreg => {
                return .{
                    .fbreg = @bitCast(dw_operand1),
                };
            },
            else => {
                return .{
                    .unknown = .{
                        .op = dw_operator_out,
                        .opd1 = dw_operand1,
                        .opd2 = dw_operand2,
                        .opd3 = dw_operand3,
                    },
                };
            },
        }
    }
};

pub const DebugDump = struct {
    // name owned by DwarfInfo/static memory
    name: []const u8,
    tag: []const u8,
    op: ?DwOp = null,
    children: []DebugDump,

    pub fn deinit(self: *DebugDump, alloc: Allocator) void {
        for (self.children) |*child| {
            child.deinit(alloc);
        }
        alloc.free(self.children);
    }

    pub fn init(alloc: Allocator, exe: [:0]const u8) ![]DebugDump {
        var dbg = try dwarfDbgFromPath(exe);
        var cu_it = try CompilationUnitIt.init(&dbg);
        var it = DwarfIt.init(alloc, &cu_it);
        defer it.deinit();

        var children_bufs: std.ArrayListUnmanaged(std.ArrayListUnmanaged(DebugDump)) = .{};
        defer {
            for (children_bufs.items) |*item| {
                for (item.items) |*serialized_die| {
                    serialized_die.deinit(alloc);
                }
                item.deinit(alloc);
            }
            children_bufs.deinit(alloc);
        }

        while (try it.next()) |item| {
            defer item.deinit();
            const name = item.die.name() catch "unknown";

            while (children_bufs.items.len < item.level) {
                try children_bufs.append(alloc, .{});
            }

            var children: []DebugDump = &.{};
            errdefer alloc.free(children);

            if (children_bufs.items.len > item.level) {
                //collect children into new DebugDump
                std.debug.assert(item.level + 1 == children_bufs.items.len);

                var children_al = children_bufs.pop();
                children = try children_al.toOwnedSlice(alloc);
            }

            const tag = try item.die.tag();

            var serialized = DebugDump{
                .name = name,
                .tag = tagString(tag),
                .children = children,
            };

            if (tag == libdwarf.DW_TAG_variable) {
                const op = try DwOp.init(item.die);
                serialized.op = op;
            }

            try children_bufs.items[children_bufs.items.len - 1].append(alloc, serialized);
        }

        std.debug.assert(children_bufs.items.len == 1);
        var ret_al = children_bufs.pop();
        return try ret_al.toOwnedSlice(alloc);
    }
};

const DwarfIt = struct {
    it: *CompilationUnitIt,
    stack: std.ArrayList(DwarfDie),

    const Output = struct {
        level: usize,
        die: DwarfDie,

        fn deinit(self: *const Output) void {
            self.die.deinit();
        }
    };

    pub fn init(alloc: Allocator, it: *CompilationUnitIt) DwarfIt {
        return .{
            .it = it,
            .stack = std.ArrayList(DwarfDie).init(alloc),
        };
    }

    pub fn deinit(self: *DwarfIt) void {
        for (self.stack.items) |item| {
            item.deinit();
        }
        self.stack.deinit();
    }

    pub fn next(self: *DwarfIt) !?Output {
        if (self.stack.items.len == 0) {
            if (try self.it.next()) |item| {
                try self.stack.append(item);
                try self.pushWhileHasChild();
            } else {
                return null;
            }
        }

        const child = &self.stack.items[self.stack.items.len - 1];
        if (try child.nextSibling()) |sibling| {
            const die = child.*;
            errdefer die.deinit();

            child.* = sibling;
            const level = self.stack.items.len;
            try self.pushWhileHasChild();
            return .{
                .level = level,
                .die = die,
            };
        } else {
            defer _ = self.stack.popOrNull();
            return .{
                .level = self.stack.items.len,
                .die = child.*,
            };
        }
    }

    fn pushWhileHasChild(self: *DwarfIt) !void {
        var it = self.stack.getLast();
        while (try it.child()) |child| {
            try self.stack.append(child);
            it = child;
        }
    }
};

fn dwarfDbgFromPath(exe: [:0]const u8) !libdwarf.Dwarf_Debug {
    var dbg: libdwarf.Dwarf_Debug = undefined;

    const ret = libdwarf.dwarf_init_path(exe, null, 0, libdwarf.DW_GROUPNUMBER_ANY, null, null, &dbg, null);

    if (ret != libdwarf.DW_DLV_OK) {
        return error.DwarfInitError;
    }
    return dbg;
}

const DieRange = struct {
    start: u64,
    end: u64,
};

const CompilationUnits = struct {
    const CompilationUnitRange = struct { range: DieRange, die: u32 };
    ranges: []CompilationUnitRange,
    compilation_unit_dies: []DwarfDie,

    const Builder = struct {
        alloc: Allocator,
        ranges: std.ArrayListUnmanaged(CompilationUnitRange) = .{},
        compilation_unit_dies: std.ArrayListUnmanaged(DwarfDie) = .{},

        pub fn deinit(self: *Builder) void {
            self.ranges.deinit(self.alloc);
            self.compilation_unit_dies.deinit(self.alloc);
        }

        pub fn push(self: *Builder, die: DwarfDie) !usize {
            try self.compilation_unit_dies.append(self.alloc, die);
            return self.compilation_unit_dies.items.len - 1;
        }

        pub fn pushRange(self: *Builder, range: DieRange, idx: u32) !void {
            if (range.start == 0 and range.end == 0) {
                return;
            }

            try self.ranges.append(self.alloc, .{
                .range = range,
                .die = idx,
            });
        }

        pub fn build(self: *Builder) !CompilationUnits {
            sortRanges(self.ranges.items);
            try mergeSortedRanges(self.alloc, &self.ranges);

            return .{
                .ranges = try self.ranges.toOwnedSlice(self.alloc),
                .compilation_unit_dies = try self.compilation_unit_dies.toOwnedSlice(self.alloc),
            };
        }

        fn sortRanges(ranges: []CompilationUnitRange) void {
            const fnLessThan = struct {
                fn f(_: void, lhs: CompilationUnitRange, rhs: CompilationUnitRange) bool {
                    return lhs.range.start < rhs.range.start;
                }
            }.f;
            std.sort.pdq(CompilationUnitRange, ranges, {}, fnLessThan);
        }

        fn mergeSortedRanges(alloc: Allocator, ranges: *std.ArrayListUnmanaged(CompilationUnitRange)) !void {
            var squashed_ranges = std.ArrayListUnmanaged(CompilationUnitRange){};
            defer squashed_ranges.deinit(alloc);
            for (ranges.items) |item| {
                if (squashed_ranges.items.len > 0) {
                    const last = &squashed_ranges.items[squashed_ranges.items.len - 1];
                    if (last.die == item.die) {
                        last.range.end = item.range.end;
                        continue;
                    }
                }
                try squashed_ranges.append(alloc, item);
            }
            std.mem.swap(@TypeOf(ranges.*), ranges, &squashed_ranges);
        }
    };

    pub fn deinit(self: *CompilationUnits, alloc: Allocator) void {
        alloc.free(self.ranges);

        for (self.compilation_unit_dies) |die| {
            die.deinit();
        }

        alloc.free(self.compilation_unit_dies);
    }

    pub fn getForIp(self: *const CompilationUnits, instruction_pointer: u64) DwarfDie {
        const itemLessThan = struct {
            fn f(_: void, lhs: u64, rhs: CompilationUnitRange) bool {
                return lhs < rhs.range.start;
            }
        }.f;
        const upper = upperBound(CompilationUnitRange, instruction_pointer, self.ranges, {}, itemLessThan);
        const range = self.ranges[upper -| 1];
        return self.compilation_unit_dies[range.die];
    }
};

pub const SourceLocation = struct {
    path: []const u8,
    line: i32,

    pub fn deinit(self: *SourceLocation, alloc: Allocator) void {
        alloc.free(self.path);
    }

    pub fn eql(self: SourceLocation, other: SourceLocation) bool {
        comptime std.debug.assert(std.meta.fields(SourceLocation).len == 2);
        return std.mem.eql(u8, self.path, other.path) and self.line == other.line;
    }
};

pub const DwarfInfo = struct {
    dbg: libdwarf.Dwarf_Debug,
    functions: []Function,
    compilation_units: CompilationUnits,

    const Function = struct {
        range: DieRange,
        die: DwarfDie,
    };

    pub const Diagnostics = struct {
        alloc: Allocator,
        unhandled_fns: std.StringHashMapUnmanaged(void) = .{},
        string_storage: std.ArrayListUnmanaged([]const u8) = .{},

        pub fn deinit(self: *Diagnostics) void {
            self.unhandled_fns.deinit(self.alloc);
            for (self.string_storage.items) |item| {
                self.alloc.free(item);
            }
            self.string_storage.deinit(self.alloc);
        }

        fn pushUnhandledFn(self: *Diagnostics, unowned_name: []const u8) !void {
            const name = try self.alloc.dupe(u8, unowned_name);
            errdefer self.alloc.free(name);

            try self.string_storage.append(self.alloc, name);
            errdefer _ = self.string_storage.pop();

            try self.unhandled_fns.put(self.alloc, name, {});
        }
    };

    pub fn init(alloc: Allocator, exe: [:0]const u8, diagnostics: ?*Diagnostics) !DwarfInfo {
        var dbg = try dwarfDbgFromPath(exe);
        errdefer _ = libdwarf.dwarf_finish(dbg);

        var cu_it = try CompilationUnitIt.init(&dbg);
        var dwarf_it = DwarfIt.init(alloc, &cu_it);
        defer dwarf_it.deinit();

        var functions = std.ArrayList(Function).init(alloc);
        defer functions.deinit();

        var compilation_units = CompilationUnits.Builder{ .alloc = alloc };
        defer compilation_units.deinit();

        while (try dwarf_it.next()) |item| {
            const die = item.die;

            switch (try die.tag()) {
                // FIXME: DW_TAG_inlined_subroutine + DW_TAG_entry_point
                libdwarf.DW_TAG_subprogram => {
                    errdefer die.deinit();
                    // FIXME: These don't have to be addr/u64
                    var low_attr = die.attr(libdwarf.DW_AT_low_pc) catch {
                        die.deinit();
                        if (diagnostics) |d| {
                            const name = item.die.name() catch "unknown";
                            try d.pushUnhandledFn(name);
                        }
                        continue;
                    };

                    defer low_attr.deinit();
                    const low_val = try low_attr.asAddr();

                    var high_attr = try die.attr(libdwarf.DW_AT_high_pc);
                    defer high_attr.deinit();
                    const high_val = try high_attr.asU64();

                    try functions.append(.{
                        .range = .{
                            .start = low_val,
                            .end = low_val + high_val,
                        },
                        .die = die,
                    });
                },
                libdwarf.DW_TAG_compile_unit => {
                    const die_idx = try compilation_units.push(die);
                    var dw_return_realoffset: libdwarf.Dwarf_Off = undefined;
                    var dw_rangesbuf: ?[*]libdwarf.Dwarf_Ranges = undefined;
                    var dw_rangecount: libdwarf.Dwarf_Signed = undefined;
                    var dw_bytecount: libdwarf.Dwarf_Unsigned = undefined;

                    var ranges_attr = try die.attr(libdwarf.DW_AT_ranges);
                    defer ranges_attr.deinit();

                    const err = libdwarf.dwarf_get_ranges_b(
                        dbg,
                        try ranges_attr.asGlobalOffs(),
                        die.die,
                        &dw_return_realoffset,
                        &dw_rangesbuf,
                        &dw_rangecount,
                        &dw_bytecount,
                        null,
                    );

                    if (err != libdwarf.DW_DLV_OK) {
                        return error.ErrorGettingRanges;
                    }

                    for (0..@as(usize, @intCast(dw_rangecount))) |i| {
                        try compilation_units.pushRange(.{
                            .start = dw_rangesbuf.?[i].dwr_addr1,
                            .end = dw_rangesbuf.?[i].dwr_addr2,
                        }, @intCast(die_idx));
                    }
                },
                else => {
                    die.deinit();
                },
            }
        }

        const fnLessThan = struct {
            fn f(_: void, lhs: Function, rhs: Function) bool {
                return lhs.range.start < rhs.range.start;
            }
        }.f;

        std.sort.pdq(Function, functions.items, {}, fnLessThan);

        return .{
            .dbg = dbg,
            .functions = try functions.toOwnedSlice(),
            .compilation_units = try compilation_units.build(),
        };
    }

    pub fn deinit(self: *DwarfInfo, alloc: Allocator) void {
        for (self.functions) |f| {
            f.die.deinit();
        }
        self.compilation_units.deinit(alloc);
        alloc.free(self.functions);
        _ = libdwarf.dwarf_finish(self.dbg);
    }

    pub fn getDieForInstruction(self: *const DwarfInfo, addr: u64) *const DwarfDie {
        const itemLessThan = struct {
            fn f(_: void, lhs: u64, rhs: Function) bool {
                return lhs < rhs.range.start;
            }
        }.f;

        const upper = upperBound(Function, addr, self.functions, {}, itemLessThan);

        return &self.functions[upper -| 1].die;
    }

    pub fn sourceLocation(self: *const DwarfInfo, alloc: Allocator, instruction_pointer: u64, debug_line: []const u8) !SourceLocation {
        const cu_die = self.compilation_units.getForIp(instruction_pointer);
        var stmt_list_attr = try cu_die.attr(libdwarf.DW_AT_stmt_list);
        defer stmt_list_attr.deinit();

        const stmt_list_offs = try stmt_list_attr.asGlobalOffs();
        const prog = debug_line[stmt_list_offs..];
        var fbr = std.io.fixedBufferStream(prog);
        const reader = fbr.reader();

        var lpm = try lineProgramMachine(alloc, reader);
        defer lpm.deinit(alloc);

        const best_match = try findMatchingSnapshot(&lpm, instruction_pointer);
        const file_path = try resolveLpmPath(alloc, cu_die, lpm.header, best_match.file);
        errdefer alloc.free(file_path);

        return .{
            .path = file_path,
            .line = best_match.line,
        };
    }

    fn resolveLpmPath(alloc: Allocator, cu_die: DwarfDie, header: LineNumberProgramHeader, file_idx: usize) ![]const u8 {
        const file_info = header.file_names[file_idx - 1];

        const dir_name = if (file_info.dir_idx > 0) blk: {
            break :blk header.include_directories[file_info.dir_idx - 1];
        } else blk: {
            var attr = try cu_die.attr(libdwarf.DW_AT_comp_dir);
            defer attr.deinit();
            break :blk try attr.asString();
        };

        return try std.fs.path.join(alloc, &.{ dir_name, file_info.name });
    }
};

fn findMatchingSnapshot(lpm: anytype, instruction_pointer: u64) !@TypeOf(lpm.*).Snapshot {
    var best_match_addr: u64 = 0;
    var best_match: @TypeOf(lpm.*).Snapshot = undefined;

    while (try lpm.next()) |item| {
        if (best_match_addr < item.address and item.address <= instruction_pointer) {
            best_match_addr = item.address;
            best_match = item;
        }
    }

    return best_match;
}

// NOTE: upperBound API cannot handle mis-matched types in 0.13 (I think, didn't actually check but pretty sure)
fn upperBound(
    comptime T: type,
    key: anytype,
    items: []const T,
    context: anytype,
    comptime lessThan: fn (context: @TypeOf(context), lhs: @TypeOf(key), rhs: T) bool,
) usize {
    var left: usize = 0;
    var right: usize = items.len;

    while (left < right) {
        const mid = (right + left) / 2;
        if (!lessThan(context, key, items[mid])) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return left;
}

// FIXME: Detect if we're in 32 or 64 bit mode
// FIXME: We probably don't actually need this, we can prune fields that we
// don't care about

const LineNumberProgramHeader = struct {
    unit_length: u32,
    // FIXME: Surely we should do something with this
    version: u16,
    header_length: u32,
    minimum_instruction_length: u8,
    maximum_operations_per_instruction: u8,
    default_is_stmt: u8,
    line_base: i8,
    line_range: u8,
    opcode_base: u8,
    // FIXME: Should we do something with this?
    standard_opcode_lengths: []u64,
    include_directories: [][]const u8,
    file_names: []FileName,
    in_header_bytes: usize,

    fn init(alloc: Allocator, in_reader: anytype) !LineNumberProgramHeader {
        const unit_length = try in_reader.readInt(u32, .little);

        // Only 32 bit header parsing is implemented
        // Only 32 bit header parsing with small unit lengths implemented
        std.debug.assert(unit_length < 0xfffffff0);

        var counting_reader = std.io.countingReader(in_reader);
        const reader = counting_reader.reader();

        const version = try reader.readInt(u16, .little);
        // FIXME: Validate read length matches header length
        const header_length = try reader.readInt(u32, .little);
        const minimum_instruction_length = try reader.readInt(u8, .little);
        const maximum_operations_per_instruction = try reader.readInt(u8, .little);
        const default_is_stmt = try reader.readInt(u8, .little);
        const line_base = try reader.readInt(i8, .little);
        const line_range = try reader.readInt(u8, .little);
        const opcode_base = try reader.readInt(u8, .little);

        const standard_opcode_lengths = try readStandardOpcodeLengths(alloc, opcode_base, reader);
        errdefer alloc.free(standard_opcode_lengths);

        const include_directories = try readIncludeDirectories(alloc, reader);
        errdefer deinitIncludeDirs(alloc, include_directories);

        const file_names = try readFileNames(alloc, reader);
        errdefer deinitFileNames(file_names);

        return .{
            .unit_length = unit_length,
            .version = version,
            .header_length = header_length,
            .minimum_instruction_length = minimum_instruction_length,
            .maximum_operations_per_instruction = maximum_operations_per_instruction,
            .default_is_stmt = default_is_stmt,
            .line_base = line_base,
            .line_range = line_range,
            .opcode_base = opcode_base,
            .standard_opcode_lengths = standard_opcode_lengths,
            .include_directories = include_directories,
            .file_names = file_names,
            .in_header_bytes = counting_reader.bytes_read,
        };
    }

    fn deinit(self: *LineNumberProgramHeader, alloc: Allocator) void {
        alloc.free(self.standard_opcode_lengths);
        deinitIncludeDirs(alloc, self.include_directories);
        deinitFileNames(alloc, self.file_names);
    }

    fn dataLength(self: *const LineNumberProgramHeader) usize {
        return self.unit_length - self.in_header_bytes;
    }

    fn readStandardOpcodeLengths(alloc: Allocator, opcode_base: u8, reader: anytype) ![]u64 {
        var standard_opcode_lengths = std.ArrayList(u64).init(alloc);
        defer standard_opcode_lengths.deinit();

        for (1..opcode_base - 1) |_| {
            const val = try std.leb.readULEB128(u64, reader);
            try standard_opcode_lengths.append(val);
        }

        return try standard_opcode_lengths.toOwnedSlice();
    }

    fn readIncludeDirectories(alloc: Allocator, reader: anytype) ![][]const u8 {
        var include_directories = std.ArrayList([]const u8).init(alloc);
        defer {
            for (include_directories.items) |d| {
                alloc.free(d);
            }
            include_directories.deinit();
        }

        while (true) {
            const p = try reader.readUntilDelimiterAlloc(alloc, 0, 1_000_000);
            if (p.len == 0) {
                break;
            }
            try include_directories.append(p);
        }

        return try include_directories.toOwnedSlice();
    }

    fn deinitIncludeDirs(alloc: Allocator, include_directories: []const []const u8) void {
        for (include_directories) |d| {
            alloc.free(d);
        }
        alloc.free(include_directories);
    }

    fn readFileNames(alloc: Allocator, reader: anytype) ![]FileName {
        var file_names = std.ArrayList(FileName).init(alloc);
        defer {
            for (file_names.items) |*item| {
                item.deinit(alloc);
            }
            file_names.deinit();
        }

        while (true) {
            const f = try FileName.init(alloc, reader) orelse break;
            try file_names.append(f);
        }

        return try file_names.toOwnedSlice();
    }

    fn deinitFileNames(alloc: Allocator, file_names: []FileName) void {
        for (file_names) |*f| {
            f.deinit(alloc);
        }
        alloc.free(file_names);
    }

    const FileName = struct {
        name: []const u8,
        dir_idx: u64,
        mtime: u64,
        size: u64,

        fn init(alloc: Allocator, reader: anytype) !?FileName {
            const p = try reader.readUntilDelimiterAlloc(alloc, 0, 1_000_000);

            if (p.len == 0) {
                return null;
            }

            return .{
                .name = p,
                .dir_idx = try std.leb.readULEB128(u64, reader),
                .mtime = try std.leb.readULEB128(u64, reader),
                .size = try std.leb.readULEB128(u64, reader),
            };
        }

        fn deinit(self: *FileName, alloc: Allocator) void {
            alloc.free(self.name);
        }
    };
};

const DwarfLns = enum(u8) {
    copy = 1,
    advance_pc,
    advance_line,
    set_file,
    set_column,
    negate_stmt,
    set_basic_block,
    const_add_pc,
    fixed_advance_pc,
    set_prologue_end,
    set_epilogue_begin,
    set_isa,
};

const DwarfLne = enum(u8) {
    end_sequence = 1,
    set_address,
    define_file,
    set_descriminator,
    lo_user,
    hi_user,
};

/// Line prgram machine modeled after DWARF 4 specification section 6.2, tested
/// on a zig executable
pub fn LineProgramMachine(comptime Reader: type) type {
    return struct {
        const Self = @This();
        header: LineNumberProgramHeader,
        counting_reader: std.io.CountingReader(Reader),
        state: Snapshot,

        pub const Snapshot = struct {
            address: u64 = 0,
            op_index: u32 = 0,
            file: u32 = 1,
            line: i32 = 1,
            column: u32 = 0,
            is_stmt: bool,
            basic_block: bool = false,
            end_sequence: bool = false,
            prologue_end: bool = false,
            epilogue_begin: bool = false,
            isa: u32 = 0,
            discriminator: u32 = 0,
            fn init(header: LineNumberProgramHeader) Snapshot {
                return .{
                    .is_stmt = header.default_is_stmt > 0,
                };
            }
        };

        pub fn init(alloc: Allocator, reader: Reader) !Self {
            const header = try LineNumberProgramHeader.init(alloc, reader);
            return .{
                .header = header,
                .counting_reader = std.io.countingReader(reader),
                .state = Snapshot.init(header),
            };
        }

        pub fn deinit(self: *Self, alloc: Allocator) void {
            self.header.deinit(alloc);
        }

        pub fn next(self: *Self) !?Snapshot {
            while (true) {
                if (self.counting_reader.bytes_read >= self.header.dataLength()) {
                    return null;
                }
                switch (try self.step()) {
                    .output => |o| return o,
                    .cont => continue,
                }
            }
        }

        const StepAction = union(enum) {
            output: ?Snapshot,
            cont,
        };

        fn step(self: *Self) !StepAction {
            const reader = self.counting_reader.reader();
            const op = try reader.readByte();

            if (op >= self.header.opcode_base) {
                return .{ .output = self.doSpecialOp(op) };
            } else if (op == 0) {
                return try self.doExtendedOp();
            } else {
                return try self.doStandardOp(op);
            }
        }

        fn doSpecialOp(self: *Self, op: u8) Snapshot {
            // std.log.debug("got special op: {d}", .{op});
            const adjusted_opcode = self.calcAdjustedOpcode(op);
            const operation_advance = self.calcOperationAdvance(op);

            self.advanceOperation(operation_advance);
            self.state.line += self.header.line_base + @as(i32, (adjusted_opcode % self.header.line_range));
            self.state.basic_block = false;
            self.state.prologue_end = false;
            self.state.epilogue_begin = false;
            self.state.discriminator = 0;

            return self.state;
        }

        fn advanceOperation(self: *Self, operation_advance: anytype) void {
            var instruction_advance: u32 = self.header.minimum_instruction_length;
            instruction_advance *= (self.state.op_index + operation_advance) / self.header.maximum_operations_per_instruction;
            const new_op_index = (self.state.op_index + operation_advance) % self.header.maximum_operations_per_instruction;
            self.state.address += instruction_advance;
            self.state.op_index = new_op_index;
        }

        fn calcAdjustedOpcode(self: *const Self, op: u8) u8 {
            return op - self.header.opcode_base;
        }

        fn calcOperationAdvance(self: *const Self, op: u8) u8 {
            const adjusted = self.calcAdjustedOpcode(op);
            return adjusted / self.header.line_range;
        }

        fn doStandardOp(self: *Self, op: u8) !StepAction {
            const reader = self.counting_reader.reader();
            const standard_op = std.meta.intToEnum(DwarfLns, op) catch {
                return error.UnknownOp;
            };

            // std.log.debug("got standard op: {s}", .{@tagName(standard_op)});

            switch (standard_op) {
                .copy => {
                    const ret = self.state;
                    self.state.discriminator = 0;
                    self.state.basic_block = false;
                    self.state.prologue_end = false;
                    self.state.epilogue_begin = false;
                    return .{ .output = ret };
                },
                .advance_pc => {
                    const val = try std.leb.readULEB128(u32, reader);
                    self.advanceOperation(val);
                },
                .advance_line => {
                    self.state.line += try std.leb.readILEB128(@TypeOf(self.state.line), reader);
                },
                .set_file => {
                    self.state.file = try std.leb.readULEB128(@TypeOf(self.state.file), reader);
                },
                .set_column => {
                    self.state.column = try std.leb.readULEB128(@TypeOf(self.state.column), reader);
                },
                .negate_stmt => {
                    self.state.is_stmt = !self.state.is_stmt;
                },
                .const_add_pc => {
                    self.advanceOperation(self.calcOperationAdvance(255));
                },
                .set_prologue_end => self.state.prologue_end = true,
                .set_epilogue_begin => self.state.epilogue_begin = true,
                else => {
                    std.log.err("unhandled op: {s}", .{@tagName(standard_op)});
                    return error.UnhandledOp;
                },
            }
            return .cont;
        }

        fn doExtendedOp(self: *Self) !StepAction {
            const reader = self.counting_reader.reader();
            const extended_op_len = try std.leb.readULEB128(@TypeOf(self.state.file), reader);
            const extended_op_raw = try reader.readByte();

            const extended_op = std.meta.intToEnum(DwarfLne, extended_op_raw) catch {
                return error.UnknownOp;
            };

            // std.log.debug("got extended op: {s}", .{@tagName(extended_op)});

            // FIXME: Validate read bytes == extended_op_len
            switch (extended_op) {
                .set_address => {
                    // FIXME: 8 byte assumption
                    // 1 byte op, 8 bytes ptr
                    // Assuming 64bit machine, invalid assumption but good enough for me for now
                    std.debug.assert(extended_op_len == 1 + 8);
                    var new_address: u64 = undefined;
                    const read_bytes = try reader.readAll(std.mem.asBytes(&new_address));
                    if (read_bytes != @sizeOf(@TypeOf(new_address))) {
                        return error.UnexpectedEof;
                    }
                    self.state.address = new_address;
                    self.state.op_index = 0;
                    return .cont;
                },
                .end_sequence => {
                    self.state.end_sequence = true;
                    const ret = self.state;
                    self.state = Snapshot.init(self.header);
                    return .{ .output = ret };
                },
                else => {
                    std.log.err("unhandled extended op: {s}", .{@tagName(extended_op)});
                    return error.UnhandledOp;
                },
            }
        }
    };
}

fn lineProgramMachine(alloc: Allocator, debug_line_reader: anytype) !LineProgramMachine(@TypeOf(debug_line_reader)) {
    return LineProgramMachine(@TypeOf(debug_line_reader)).init(alloc, debug_line_reader);
}
