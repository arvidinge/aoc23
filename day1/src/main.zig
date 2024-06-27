// imports
const std = @import("std");
const types = @import("types.zig");
const string = @import("string.zig");

// typedefs
const ArgumentError = error{
    NotExactlyOneArgument
};
const DataError = error{
    NoDigitInLine  
};

// aliases
const Allocator = std.mem.Allocator;

// constants
const SIZE_2MB: u32 = 2000000;


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    // Get the single expected cli arg pointing out the input file
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip(); // skip "zig" arg
    const arg = args.next() orelse return ArgumentError.NotExactlyOneArgument;
    if (args.next() != null) {
        return ArgumentError.NotExactlyOneArgument;
    }

    // Find the file in cwd and read it
    const cwd = std.fs.cwd();
    const inputFile = try cwd.openFile(arg, std.fs.File.OpenFlags{.mode = std.fs.File.OpenMode.read_only});
    const content = try inputFile.readToEndAlloc(allocator, SIZE_2MB);
    defer allocator.free(content);

    // Split content by line
    const lines = try string.splitString(allocator, content, "\n");

    var sum: u32 = 0;
    for (lines, 0..lines.len) |line, i| {
        _=i;
        // std.debug.print("line {d}: {s}\r\n", .{i, line});
        sum += (getFirstDigit(line) orelse return DataError.NoDigitInLine) * 10;
        sum += (getLastDigit(line) orelse return DataError.NoDigitInLine);
        // std.debug.print("\r\n", .{});
    }

    std.debug.print("sum: {d}\r\n", .{sum});
}

pub fn getFirstDigit(str: [] const u8) ?u8 {
    for (str) |ch| {
        if (ch >= 48 and ch <= 57) return ch - 48;
    }
    return undefined;
}

pub fn getLastDigit(str: [] const u8) ?u8 {
    var i = str.len - 1;
    if (i <= 0) return undefined;
    while (i>=0) : (i-=1) {
        if (str[i] >= 48 and str[i] <= 57) return str[i] - 48;
    }
    return undefined;
}
  