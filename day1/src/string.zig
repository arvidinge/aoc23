const std = @import("std");
const Allocator = std.mem.Allocator;


/// Split the string by the delimiter, starting from the left.
/// Best to use arena allocator, each individual [] const u8 must be freed.
pub fn splitString(allocator: Allocator, string: [] const u8, delimiter: [] const u8) ![]const []const u8 {
    var slices = std.ArrayList([] const u8).init(allocator);
    defer slices.deinit();

    if (
        delimiter.len > string.len
        or delimiter.len == 0
        or string.len == 0
    ) {
        return &.{try allocator.dupe(u8, string)};
    }
    
    // find all instances of the delimiter in the string. add their starting indexes to "delimiters"
    var curStart: usize = 0;
    var curOffset: usize = 0;
    var delimiterList = std.ArrayList(usize).init(allocator);
    defer delimiterList.deinit();

    while (curStart < string.len) {
        const match = while (curOffset < delimiter.len) : (curOffset += 1) {
            if (string[curStart + curOffset] != delimiter[curOffset]) {
                break false;
            } else {

            }
        } else true;

        if (match) {
            try delimiterList.append(curStart);
            curStart += curOffset;
        } else {
            curStart += 1;
        }
        curOffset = 0;
    }

    const delimiters: []usize = try delimiterList.toOwnedSlice();

    if (delimiters.len == 0) {
        return &.{try allocator.dupe(u8, string)};
    } 

    curStart = 0;
    for (delimiters) |delim| {
        try slices.append(try allocator.dupe(u8, string[curStart..delim]));
        curStart = delim + delimiter.len;
    }
    try slices.append(try allocator.dupe(u8, string[(delimiters[delimiters.len-1] + delimiter.len)..]));

    return slices.toOwnedSlice();
}
