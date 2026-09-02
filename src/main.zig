const std = @import("std");
const ghostty = @import("ghostty.zig");
const palette = @import("palette.zig");
const vscode = @import("vscode.zig");
const web = @import("web.zig");

const Command = enum { generate, check, list, help };

const Options = struct {
    command: Command = .generate,
    output_dir: []const u8 = "themes",
    variant: ?palette.Variant = null,
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);
    const options = parseArgs(args) catch |err| {
        std.debug.print("error: {s}\n\n", .{@errorName(err)});
        printHelp();
        return err;
    };

    switch (options.command) {
        .help => printHelp(),
        .list => {
            var buffer: [1024]u8 = undefined;
            var file_writer: std.Io.File.Writer = .init(.stdout(), init.io, &buffer);
            const writer = &file_writer.interface;
            for (palette.variants) |variant| {
                try writer.print("{s}\t{s}\n", .{ variant.slug, variant.label });
            }
            try writer.flush();
        },
        .generate => try generate(init.io, allocator, options, false),
        .check => try generate(init.io, allocator, options, true),
    }
}

fn parseArgs(args: []const []const u8) !Options {
    var options = Options{};
    var index: usize = 1;
    if (index < args.len and !std.mem.startsWith(u8, args[index], "--")) {
        options.command = if (std.mem.eql(u8, args[index], "generate"))
            .generate
        else if (std.mem.eql(u8, args[index], "check"))
            .check
        else if (std.mem.eql(u8, args[index], "list"))
            .list
        else if (std.mem.eql(u8, args[index], "help"))
            .help
        else
            return error.UnknownCommand;
        index += 1;
    }

    while (index < args.len) : (index += 1) {
        const arg = args[index];
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            options.command = .help;
        } else if (std.mem.eql(u8, arg, "--output")) {
            index += 1;
            if (index >= args.len) return error.MissingOutputDirectory;
            options.output_dir = args[index];
        } else if (std.mem.eql(u8, arg, "--variant")) {
            index += 1;
            if (index >= args.len) return error.MissingVariant;
            options.variant = palette.findVariant(args[index]) orelse return error.UnknownVariant;
        } else {
            return error.UnknownArgument;
        }
    }
    return options;
}

fn generate(io: std.Io, allocator: std.mem.Allocator, options: Options, check: bool) !void {
    const vscode_dir = try std.fs.path.join(allocator, &.{ options.output_dir, "vscode" });
    const ghostty_dir = try std.fs.path.join(allocator, &.{ options.output_dir, "ghostty" });
    const web_dir = try std.fs.path.join(allocator, &.{ options.output_dir, "web" });

    if (!check) {
        try std.Io.Dir.cwd().createDirPath(io, vscode_dir);
        try std.Io.Dir.cwd().createDirPath(io, ghostty_dir);
        if (options.variant == null) try std.Io.Dir.cwd().createDirPath(io, web_dir);
    }

    if (options.variant) |variant| {
        try processVariant(io, allocator, vscode_dir, ghostty_dir, variant, check);
    } else {
        for (palette.variants) |variant| {
            try processVariant(io, allocator, vscode_dir, ghostty_dir, variant, check);
        }
        try processWeb(io, allocator, web_dir, check);
    }
}

fn processWeb(io: std.Io, allocator: std.mem.Allocator, output_dir: []const u8, check: bool) !void {
    const content = try web.render(allocator, &palette.variants);
    defer allocator.free(content);
    const path = try std.fs.path.join(allocator, &.{ output_dir, "dark-fire.css" });
    defer allocator.free(path);

    if (check) {
        try checkFile(io, allocator, path, content);
    } else {
        try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = path, .data = content });
        std.debug.print("generated web stylesheet\n", .{});
    }
}

fn processVariant(
    io: std.Io,
    allocator: std.mem.Allocator,
    vscode_dir: []const u8,
    ghostty_dir: []const u8,
    variant: palette.Variant,
    check: bool,
) !void {
    const vscode_content = try vscode.render(allocator, variant);
    defer allocator.free(vscode_content);
    const ghostty_content = try ghostty.render(allocator, variant);
    defer allocator.free(ghostty_content);

    const vscode_path = try std.fs.path.join(allocator, &.{ vscode_dir, variant.vscode_file });
    defer allocator.free(vscode_path);
    const ghostty_path = try std.fs.path.join(allocator, &.{ ghostty_dir, variant.ghostty_file });
    defer allocator.free(ghostty_path);

    if (check) {
        try checkFile(io, allocator, vscode_path, vscode_content);
        try checkFile(io, allocator, ghostty_path, ghostty_content);
    } else {
        try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = vscode_path, .data = vscode_content });
        try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = ghostty_path, .data = ghostty_content });
        std.debug.print("generated {s}\n", .{variant.label});
    }
}

fn checkFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8, expected: []const u8) !void {
    const actual = std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(16 * 1024 * 1024)) catch |err| {
        std.debug.print("stale: {s} ({s})\n", .{ path, @errorName(err) });
        return error.GeneratedFilesAreStale;
    };
    defer allocator.free(actual);
    if (!std.mem.eql(u8, actual, expected)) {
        std.debug.print("stale: {s}\n", .{path});
        return error.GeneratedFilesAreStale;
    }
}

fn printHelp() void {
    std.debug.print(
        \\Usage: dark-fire [generate|check|list] [options]
        \\
        \\Options:
        \\  --output PATH    Output root (default: themes)
        \\  --variant SLUG  Generate or check one variant
        \\  -h, --help      Show this help
        \\
    , .{});
}

test "argument parsing selects a variant" {
    const options = try parseArgs(&.{ "dark-fire", "generate", "--variant", "darker", "--output", "out" });
    try std.testing.expectEqual(Command.generate, options.command);
    try std.testing.expectEqualStrings("darker", options.variant.?.slug);
    try std.testing.expectEqualStrings("out", options.output_dir);
}
