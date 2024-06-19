const Allocator = std.mem.Allocator;
const std = @import("std");
const SIZE_2MB: usize = 20000000;
const ArgumentError = error{
    NotExactlyOneArgument
};

const OtherError = error{
    NotExactlyOneArgument
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

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
    std.debug.print("content: {s}\n", .{content});
}
  