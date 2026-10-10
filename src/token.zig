const std = @import("std");

pub const TokenKind = enum(u8) {
    eof,
    left_bracket,
    right_bracket,
    left_paren,
    right_paren,
    left_brace,
    right_brace,
    dot,
    arrow,
    increment,
    decrement,
    ampersand,
    asterisk,
    plus,
    minus,
    flip_operator,
    bang,
    back_slash,
    percent,
    left_shift,
    right_shift,
    lt,
    gt,
    lt_eq,
    gt_eq,
    equal,
    not_equal,
    caret,
    pipe,
    and_operator,
    or_operator,
    question_mark,
    colon,
    semicolon,
    ellipsis,
    assign,
    compound_multiply,
    compound_division,
    compound_modulo,

    comment,
    comment_block_start,
    comment_block_end,
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
