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
    minus,
    asterisk,
    back_slash,
    forward_slash,

    increment,
    decrement,

    assign,
    equal,

    semicolon,
    colon,

    bang,
    not_equal,

    ampersand,
    and_operator,

    pipe,
    or_operator,

    comment,
    comment_block_start,
    comment_block_end,

    dot,
    flip_operator,

    percent,
    lt,
};

kind: TokenKind,
literal: []const u8,

const Self = @This();

pub fn new(kind: TokenKind, literal: []const u8) Self {
    return .{ .kind = kind, .literal = literal };
}

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("Token: {{ kind: {any}, literal: {s} }}", .{ self.kind, self.literal });
}
