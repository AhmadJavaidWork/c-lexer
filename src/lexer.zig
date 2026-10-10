const std = @import("std");
const Token = @import("token.zig");

input: []const u8,
ch: u8 = 0,
position: usize = 0,
read_position: usize = 0,

const Self = @This();

pub fn init(input: []const u8) Self {
    var l: Self = .{ .input = input };
    l.takeChar();
    return l;
}

pub fn nextToken(self: *Self) !Token {
    self.skipWhiteSpace();

    var token: Token = undefined;

    switch (self.ch) {
        0 => {
            token = .{
                .kind = Token.TokenKind.eof,
                .literal = "",
            };
        },
        '(' => {
            token = .{
                .kind = Token.TokenKind.left_paren,
                .literal = self.input[self.position..self.read_position],
            };
        },
        ')' => {
            token = .{
                .kind = Token.TokenKind.right_paren,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '{' => {
            token = .{
                .kind = Token.TokenKind.left_brace,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '}' => {
            token = .{
                .kind = Token.TokenKind.right_brace,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '[' => {
            token = .{
                .kind = Token.TokenKind.left_bracket,
                .literal = self.input[self.position..self.read_position],
            };
        },
        ']' => {
            token = .{
                .kind = Token.TokenKind.right_bracket,
                .literal = self.input[self.position..self.read_position],
            };
        },
        else => {
            return error.InvalidToken;
        },
    }

    self.takeChar();
    return token;
}

fn takeChar(self: *Self) void {
    if (self.read_position >= self.input.len) {
        self.ch = 0;
        self.position = self.read_position;
    } else {
        self.ch = self.input[self.read_position];
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn skipWhiteSpace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.takeChar();
    }
}

test "tokenize c" {
    var l: Self = Self.init(
        \\ ({[]})
    );

    const expected_tokens = [_]Token{
        .{ .kind = Token.TokenKind.left_paren, .literal = "(" },
        .{ .kind = Token.TokenKind.left_brace, .literal = "{" },
        .{ .kind = Token.TokenKind.left_bracket, .literal = "[" },
        .{ .kind = Token.TokenKind.right_bracket, .literal = "]" },
        .{ .kind = Token.TokenKind.right_brace, .literal = "}" },
        .{ .kind = Token.TokenKind.right_paren, .literal = ")" },
        .{ .kind = Token.TokenKind.eof, .literal = "" },
    };

    var actual_token: Token = undefined;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);

    for (expected_tokens) |et| {
        actual_token = try l.nextToken();

        try std.testing.expectEqual(et.kind, actual_token.kind);
        try std.testing.expectEqualStrings(et.literal, actual_token.literal);
    }

    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}
