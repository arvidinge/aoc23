pub const TextSplitIterator = struct {
    text: [] const u8,
    delimiter: [] const u8,

    pub fn next(self: *const TextSplitIterator) ?[] const u8 {
        if (self.text.len < self.delimiter.len) return null;

        return self.text;
    }
};