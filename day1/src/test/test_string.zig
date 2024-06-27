const std = @import("std");
const testing = std.testing;

const string = @import("../string.zig");
const SUT = string;

test "simple split" {
    try stringSplitTest(
    "hej.hopp",
    ".",
    &.{"hej", "hopp"});
}

test "multiple delimiters" {
    try stringSplitTest(
    "hej.hopp.tjosan.hejsan",
    ".",
    &.{"hej", "hopp", "tjosan", "hejsan"}); 
}

test "multichar delimiter" {
    try stringSplitTest(
    "hej..hopp",
    "..",
    &.{"hej", "hopp"});
}

test "multichar overlapping delimiter" {
    try stringSplitTest(
    "hej...hopp",
    "..",
    &.{"hej", ".hopp"});
}

test "delimiter at the start returns empty string and rest" {
    try stringSplitTest(
    "..hopp",
    "..",
    &.{"", "hopp"});
}

test "delimiter at the end returns rest and empty string" {
    try stringSplitTest(
    "hej..",
    "..",
    &.{"hej", ""});
}

test "two consecutive delimiters should return empty string between them" {
    try stringSplitTest(
    "hej..hopp",
    ".",
    &.{"hej", "", "hopp"});
}

test "string is delimiter, should return 2 empty strings" {
    try stringSplitTest(
    ".",
    ".",
    &.{"", ""});
}

test "newline split" {
    try stringSplitTest(
    "first\nsecond",
    "\n",
    &.{"first", "second"});
}

pub fn stringSplitTest(str: [] const u8, delimiter: [] const u8, expected: [] const [] const u8) !void {
    const allocator = testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    const result = try SUT.splitString(arena.allocator(), str, delimiter);
    defer arena.deinit();

    try testing.expectEqualDeep(expected, result);
}
