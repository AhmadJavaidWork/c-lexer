const std = @import("std");

pub const TokenKind = enum(u8) {
    eof,
    left_paren,
    right_paren,
    left_brace,
    right_brace,
    left_bracket,
    right_bracket,

    plus,
};

kind: TokenKind,
literal: []const u8,

const Self = @This();

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("Token: {{ kind: {any}, literal: {s} }}", .{ self.kind, self.literal });
}
