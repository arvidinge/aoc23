// imports
const std = @import("std");
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
const DIGIT_WORD = [_][] const u8 { "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};


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

    // part 1
    var sum: u32 = 0;
    for (lines) |line| {
        sum += (getFirstDigit(line) orelse 0) * 10;
        sum += (getLastDigit(line) orelse 0);
    }
    std.debug.print("part 1: {d}\r\n", .{sum});

    // part 2
    sum = 0;
    for (lines) |line| {
        sum += (getFirstTrueDigit(line) orelse 0) * 10;
        sum += (getLastTrueDigit(line) orelse 0);
        // std.debug.print("\nline: {s}\n", .{line});
        // std.debug.print("first true digit: {d}\n", .{getFirstTrueDigit(line) orelse return DataError.NoDigitInLine});
        // std.debug.print("last true digit: {d}\n", .{getLastTrueDigit(line) orelse return DataError.NoDigitInLine});
    }
    std.debug.print("part 2: {d}\r\n", .{sum});
}

pub fn getFirstDigit(str: [] const u8) ?u8 {
    for (str) |ch| {
        if (ch >= 48 and ch <= 57) return ch - 48;
    }
    return null;
}

pub fn getLastDigit(str: [] const u8) ?u8 {
    var i = (str.len - 1);
    if (i <= 0) return null;
    while (i>=0) {
        if (str[i] >= 48 and str[i] <= 57) return str[i] - 48;
        if (i > 0) i-=1 else break;
    }
    return null;
}

pub fn getFirstTrueDigit(str: [] const u8) ?u8 {
    // std.debug.print("getFirstTrueDigit --- str: {s}\n", .{str});
    var retval: ?u8 = null;

    for (0..str.len) |start| {
        // std.debug.print("start: {d}, str[start..]: {s}\n", .{start, str[start..]});

        // Check if char is digit
        const charAsDigitResult = charAsDigit(str[start]);
        // std.debug.print("charAsDigit(str[start]): {?d}\n", .{charAsDigitResult});
        if (charAsDigitResult != null) {
            retval = @intCast(charAsDigitResult.?);
        }
        if (retval != null) return retval;

        // Check if we're at the start of a digit word
        retval = for (DIGIT_WORD, 0..DIGIT_WORD.len) |digit_word, digit_index| {
            if (digit_word.len > str.len - start) continue;
            if (std.mem.startsWith(u8, str[start..], digit_word)) break @intCast(digit_index);
        } else null;
        if (retval != null) return retval;
    }

    return null;
}

pub fn getLastTrueDigit(str: [] const u8) ?u8 {
    // std.debug.print("getLastTrueDigit --- str: {s}\n", .{str});
    var retval: ?u8 = null;

    var start = str.len-1;
    while(start>=0) {
        // std.debug.print("start: {d}, str[start..]: {s}\n", .{start, str[start..]});

        // Check if char is digit
        const charAsDigitResult = charAsDigit(str[start]);
        // std.debug.print("charAsDigit(str[start]): {?d}\n", .{charAsDigitResult});
        if (charAsDigitResult != null) {
            retval = @intCast(charAsDigitResult.?);
        }
        if (retval != null) return retval;

        // Check if we're at the start of a digit word
        retval = for (DIGIT_WORD, 0..DIGIT_WORD.len) |digit_word, digit_index| {
            if (digit_word.len > str.len - start) continue;
            if (std.mem.startsWith(u8, str[start..], digit_word)) break @intCast(digit_index);
        } else null;
        if (retval != null) return retval;

        if (start > 0) start -= 1 else break;
    }

    return null;
}

pub fn charAsDigit(ch: u8) ?u8 {
    if (ch >= 48 and ch <= 57) {
        return ch - 48;
    }
    return null;
}
  