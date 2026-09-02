const std = @import("std");
const palette = @import("palette.zig");

const ColorRole = union(enum) {
    fg,
    bright_fg,
    greyscale: i8,
    red: i8,
    orange: i8,
    yellow: i8,
    green: i8,
    cyan: i8,
    blue: i8,
    purple: i8,
    keywords,
    variables,
    functions,
    types,
    interfaces,
    constants,
    enum_members,
    properties,
    namespaces,

    fn resolve(self: ColorRole, p: palette.Palette) palette.Color {
        return switch (self) {
            .fg => p.fg(),
            .bright_fg => p.brightFg(),
            .greyscale => |level| p.greyscale(level),
            .red => |level| p.red(level),
            .orange => |level| p.orange(level),
            .yellow => |level| p.yellow(level),
            .green => |level| p.green(level),
            .cyan => |level| p.cyan(level),
            .blue => |level| p.blue(level),
            .purple => |level| p.purple(level),
            .keywords => p.keywords(),
            .variables => p.variables(),
            .functions => p.functions(),
            .types => p.types(),
            .interfaces => p.interfaces(),
            .constants => p.constants(),
            .enum_members => p.enumMembers(),
            .properties => p.properties(),
            .namespaces => p.namespaces(),
        };
    }
};

const FontStyle = enum { none, bold, italic, underline, clear };

const Rule = struct {
    semantic: []const []const u8 = &.{},
    textmate: []const []const u8 = &.{},
    color: ?ColorRole = null,
    font_style: FontStyle = .none,
};

const rules = [_]Rule{
    .{
        .semantic = &.{ "keyword", "boolean", "selfParameter" },
        .textmate = &.{
            "entity.name.tag",                "keyword.operator.expression",     "keyword.operator.new",
            "keyword.operator.wordlike",      "keyword.type.elm",                "keyword.type.go",
            "keyword",                        "keyword.operator.logical.python", "keyword.operator.in",
            "punctuation.definition.heading", "storage.modifier",                "storage.type.class",
            "storage.type.enum",              "storage.type.function.python",    "storage.type.function.ts",
            "storage.type.function",          "storage.type.interface.ts",       "storage.type.js",
            "storage.type.local.java",        "storage.type.def.groovy",         "storage.type.namespace",
            "storage.type.property",          "storage.type.rust",               "storage.type.struct",
            "storage.type.ts",                "storage.type.type",               "variable.language.self",
            "variable.language.special.self", "variable.language.this",
        },
        .color = .keywords,
        .font_style = .bold,
    },
    .{ .semantic = &.{"number"}, .textmate = &.{ "constant.numeric", "keyword.other.unit" }, .color = .{ .green = 1 } },
    .{
        .semantic = &.{"string"},
        .textmate = &.{ "constant.character", "punctuation.definition.char", "punctuation.definition.string", "string" },
        .color = .{ .red = -1 },
    },
    .{ .semantic = &.{"variable"}, .textmate = &.{"variable"}, .color = .variables },
    .{ .semantic = &.{"enumMember"}, .textmate = &.{"variable.other.enummember"}, .color = .enum_members },
    .{
        .semantic = &.{ "constParameter", "variable.static" },
        .textmate = &.{ "constant", "entity.name.constant", "variable.other.metavariable", "support.constant" },
        .color = .constants,
    },
    .{
        .semantic = &.{ "function", "method" },
        .textmate = &.{
            "entity.name.function", "entity.name.function-call",              "meta.function-call.generic.python",
            "support.function",     "entity.other.attribute-name.table.toml", "entity.other.attribute-name.table.array.toml",
        },
        .color = .functions,
    },
    .{
        .semantic = &.{ "type", "class", "struct", "enum", "union", "typeAlias" },
        .textmate = &.{ "entity.name.type", "storage.type", "support.class", "support.type" },
        .color = .types,
    },
    .{
        .semantic = &.{"builtinType"},
        .textmate = &.{
            "keyword.type",           "storage.type.boolean.go", "storage.type.built-in",  "storage.type.byte.go",
            "storage.type.error.go",  "storage.type.numeric.go", "storage.type.primitive", "storage.type.rune.go",
            "storage.type.string.go", "storage.type.uintptr.go", "support.type",           "variable.other.metavariable.specifier",
        },
        .color = .{ .cyan = 0 },
    },
    .{
        .semantic = &.{"typeParameter"},
        .textmate = &.{ "entity.name.type.parameter", "variable.type" },
        .color = .{ .purple = 0 },
    },
    .{
        .semantic = &.{"property"},
        .textmate = &.{
            "entity.name.field",                   "entity.name.record.field",               "entity.name.variable.field",
            "meta.attribute.python",               "punctuation.support.type.property-name", "support.type.property-name",
            "support.type.vendored.property-name", "variable.other.member",                  "variable.other.object.property",
            "variable.other.property",
        },
        .color = .properties,
    },
    .{
        .textmate = &.{ "entity.name.tag.toml", "entity.name.tag.yaml" },
        .color = .properties,
        .font_style = .clear,
    },
    .{ .semantic = &.{"interface"}, .color = .interfaces, .font_style = .italic },
    .{ .semantic = &.{"*.trait"}, .font_style = .italic },
    .{
        .semantic = &.{"namespace"},
        .textmate = &.{
            "entity.name.module",      "entity.name.namespace",          "entity.name.type.namespace",
            "storage.modifier.import", "storage.modifier.package",       "support.module",
            "entity.name.type.module", "variable.other.constant.elixir",
        },
        .color = .namespaces,
    },
    .{
        .semantic = &.{"macro"},
        .textmate = &.{
            "entity.name.function.macro",             "entity.name.macro",                      "entity.name.other.preprocessor.macro",
            "variable.other.readwrite.module.elixir", "punctuation.definition.variable.elixir",
        },
        .color = .{ .blue = 0 },
    },
    .{
        .semantic = &.{"lifetime"},
        .textmate = &.{
            "storage.modifier.lifetime.rust", "entity.name.lifetime.rust",
            "entity.name.type.lifetime",      "punctuation.definition.lifetime",
        },
        .color = .{ .purple = 0 },
        .font_style = .italic,
    },
    .{ .semantic = &.{"escapeSequence"}, .textmate = &.{"constant.character.escape"}, .color = .{ .blue = 0 } },
    .{
        .semantic = &.{"formatSpecifier"},
        .textmate = &.{
            "constant.character.format.placeholder", "constant.other.placeholder",
            "punctuation.section.embedded",          "punctuation.definition.template-expression",
        },
        .color = .{ .blue = 0 },
    },
    .{
        .semantic = &.{"comment"},
        .textmate = &.{ "comment", "punctuation.definition.comment" },
        .color = .{ .green = -2 },
    },
    .{
        .semantic = &.{"comment.documentation"},
        .textmate = &.{"comment.line.documentation"},
        .color = .{ .green = -1 },
    },
    .{
        .semantic = &.{ "attribute", "derive" },
        .textmate = &.{
            "entity.name.function.decorator",    "punctuation.brackets.attribute",
            "punctuation.definition.annotation", "punctuation.definition.attribute",
            "punctuation.definition.decorator",  "storage.modifier.attribute",
            "storage.type.annotation",
        },
        .color = .{ .blue = 0 },
    },
    .{
        .textmate = &.{ "entity.other.attribute-name.class", "entity.other.attribute-name.id" },
        .color = .{ .cyan = -1 },
    },
    .{
        .semantic = &.{ "*.unsafe", "function.unsafe", "variable.unsafe", "operator.unsafe" },
        .textmate = &.{"keyword.other.unsafe"},
        .color = .{ .red = -2 },
    },
    .{
        .semantic = &.{"punctuation"},
        .textmate = &.{
            "keyword.operator.logical.rust", "keyword.operator", "storage.modifier.pointer",
            "storage.type.function.arrow",   "punctuation",      "keyword.control.flow.block-scalar.literal.yaml",
        },
        .color = .fg,
        .font_style = .clear,
    },
    .{ .textmate = &.{"markup.italic"}, .font_style = .italic },
    .{ .textmate = &.{"markup.bold"}, .font_style = .bold },
    .{ .textmate = &.{"markup.heading"}, .font_style = .bold },
    .{
        .textmate = &.{
            "punctuation.definition.markdown",              "punctuation.definition.heading.markdown",
            "punctuation.definition.metadata.markdown",     "punctuation.definition.raw.markdown",
            "punctuation.definition.constant.markdown",     "punctuation.definition.constant.begin.markdown",
            "punctuation.definition.constant.end.markdown", "punctuation.definition.string.begin.markdown",
            "punctuation.definition.string.end.markdown",   "punctuation.definition.list.begin.markdown",
            "punctuation.definition.quote.begin.markdown",  "punctuation.definition.bold.markdown",
            "punctuation.definition.italic.markdown",       "punctuation.separator.key-value.markdown",
            "fenced_code.block.language.markdown",          "constant.other.reference.link.markdown",
            "meta.link.inline.markdown",                    "meta.link.reference.def.markdown",
            "punctuation.definition.asciidoc",              "punctuation.separator.asciidoc",
            "support.asciidoc",                             "markup.heading.asciidoc",
            "markup.heading.marker.asciidoc",               "markup.list.bullet.asciidoc",
            "markup.link.asciidoc",                         "markup.other.url.asciidoc",
            "markup.other.anchor.asciidoc",                 "support.constant.asciidoc",
            "constant.asciidoc",                            "entity.name.function.asciidoc",
        },
        .color = .{ .green = -1 },
    },
    .{
        .textmate = &.{
            "string.other.link.title.markdown", "string.other.link.description.markdown",
            "string.unquoted.asciidoc",
        },
        .color = .fg,
    },
    .{
        .textmate = &.{ "markup.inserted", "punctuation.definition.inserted.diff" },
        .color = .{ .green = 0 },
    },
    .{
        .textmate = &.{ "markup.deleted", "punctuation.definition.deleted.diff" },
        .color = .{ .red = 0 },
    },
    .{ .textmate = &.{"markup.changed"}, .color = .{ .orange = 0 } },
    .{
        .textmate = &.{ "punctuation.definition.range.diff", "meta.diff.range" },
        .color = .{ .blue = 0 },
    },
    .{
        .textmate = &.{
            "comment.line.number-sign.git-commit", "punctuation.definition.comment.git-commit",
            "meta.diff.index",                     "meta.diff.header",
        },
        .color = .{ .greyscale = 4 },
    },
    .{
        .textmate = &.{ "meta.diff.header.to-file", "meta.diff.header.from-file" },
        .color = .bright_fg,
        .font_style = .bold,
    },
    .{
        .textmate = &.{ "punctuation.definition.from-file.diff", "punctuation.definition.to-file.diff" },
        .color = .{ .cyan = 0 },
    },
    .{ .semantic = &.{"*.mutable"}, .textmate = &.{"meta.mutable"}, .font_style = .underline },
    .{
        .semantic = &.{"unresolvedReference"},
        .color = .{ .red = -1 },
        .font_style = .underline,
    },
    .{ .semantic = &.{"magit-ref-name"}, .color = .{ .cyan = 1 }, .font_style = .bold },
    .{ .semantic = &.{"magit-remote-ref-name"}, .color = .{ .green = -2 }, .font_style = .bold },
    .{ .textmate = &.{"magit.header"}, .color = .{ .yellow = 2 }, .font_style = .bold },
    .{ .textmate = &.{"magit.subheader"}, .font_style = .bold },
    .{ .textmate = &.{"magit.entity"}, .color = .{ .greyscale = 5 } },
    .{ .textmate = &.{"invalid.deprecated.line-too-long.git-commit"}, .color = .{ .orange = 0 } },
    .{ .textmate = &.{"invalid.illegal.line-too-long.git-commit"}, .color = .{ .red = 0 } },
};

pub fn render(allocator: std.mem.Allocator, variant: palette.Variant) ![]u8 {
    var output: std.Io.Writer.Allocating = .init(allocator);
    errdefer output.deinit();
    const writer = &output.writer;

    try writer.writeAll("{\n  \"_comment\": \"Generated by dark-fire. Do not edit directly.\",\n  \"$schema\": \"vscode://schemas/color-theme\",\n  \"name\": ");
    try writeJsonString(writer, variant.label);
    try writer.writeAll(",\n  \"type\": \"dark\",\n  \"tokenColors\": [\n");
    try writeTokenColors(writer, variant.palette);
    try writer.writeAll("\n  ],\n  \"semanticHighlighting\": true,\n  \"semanticTokenColors\": {\n");
    try writeSemanticColors(writer, variant.palette);
    try writer.writeAll("\n  },\n  \"colors\": {\n");
    try writeWorkbenchColors(writer, variant.palette);
    try writer.writeAll("\n  }\n}\n");

    return output.toOwnedSlice();
}

fn writeTokenColors(writer: *std.Io.Writer, p: palette.Palette) !void {
    var first = true;
    for (rules) |rule| {
        if (rule.textmate.len == 0) continue;
        if (!first) try writer.writeAll(",\n");
        first = false;
        try writer.writeAll("    {\n      \"scope\": [");
        for (rule.textmate, 0..) |scope, index| {
            if (index != 0) try writer.writeAll(", ");
            try writeJsonString(writer, scope);
        }
        try writer.writeAll("],\n      \"settings\": {");
        var first_setting = true;
        if (rule.color) |role| {
            try writer.writeAll("\n        \"foreground\": ");
            try writeColorString(writer, role.resolve(p));
            first_setting = false;
        }
        if (rule.font_style != .none) {
            if (!first_setting) try writer.writeByte(',');
            try writer.writeAll("\n        \"fontStyle\": ");
            try writeJsonString(writer, fontStyleString(rule.font_style));
            first_setting = false;
        }
        if (!first_setting) try writer.writeAll("\n      ");
        try writer.writeAll("}\n    }");
    }
}

fn writeSemanticColors(writer: *std.Io.Writer, p: palette.Palette) !void {
    var first = true;
    inline for (.{ false, true }) |injected| {
        for (rules) |rule| {
            for (rule.semantic) |selector| {
                if (!first) try writer.writeAll(",\n");
                first = false;
                try writer.writeAll("    ");
                try writeJsonStringWithSuffix(writer, selector, if (injected) ".injected" else "");
                try writer.writeAll(": {");
                var first_setting = true;
                if (rule.color) |role| {
                    try writer.writeAll("\n      \"foreground\": ");
                    try writeColorString(writer, if (injected) role.resolve(p).withAlpha(0xaa) else role.resolve(p));
                    first_setting = false;
                } else if (injected) {
                    try writer.writeAll("\n      \"foreground\": ");
                    try writeColorString(writer, p.fg().withAlpha(0xaa));
                    first_setting = false;
                }
                try writeSemanticStyle(writer, rule.font_style, &first_setting);
                if (!first_setting) try writer.writeAll("\n    ");
                try writer.writeByte('}');
            }
        }
    }
}

fn writeSemanticStyle(writer: *std.Io.Writer, style: FontStyle, first: *bool) !void {
    switch (style) {
        .none => {},
        .bold => try writeBooleanSetting(writer, "bold", true, first),
        .italic => try writeBooleanSetting(writer, "italic", true, first),
        .underline => try writeBooleanSetting(writer, "underline", true, first),
        .clear => {
            try writeBooleanSetting(writer, "bold", false, first);
            try writeBooleanSetting(writer, "italic", false, first);
            try writeBooleanSetting(writer, "underline", false, first);
        },
    }
}

fn writeBooleanSetting(writer: *std.Io.Writer, name: []const u8, value: bool, first: *bool) !void {
    if (!first.*) try writer.writeByte(',');
    try writer.writeAll("\n      ");
    try writeJsonString(writer, name);
    try writer.writeAll(if (value) ": true" else ": false");
    first.* = false;
}

fn writeWorkbenchColors(writer: *std.Io.Writer, p: palette.Palette) !void {
    var first = true;
    try colorEntries(writer, &first, &.{"activityBar.activeBorder"}, p.fg());
    try colorEntries(writer, &first, &.{"activityBar.background"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"activityBar.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"activityBar.inactiveForeground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"activityBarBadge.background"}, p.blue(0));
    try colorEntries(writer, &first, &.{"activityBarBadge.foreground"}, p.greyscale(0));
    try colorEntries(writer, &first, &.{"badge.background"}, p.greyscale(3));
    try colorEntries(writer, &first, &.{"badge.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"button.background"}, p.blue(0));
    try colorEntries(writer, &first, &.{"button.foreground"}, p.greyscale(0));
    try colorEntries(writer, &first, &.{"button.hoverBackground"}, p.fg());
    try colorEntries(writer, &first, &.{"checkbox.background"}, p.surface(-2));
    try colorEntries(writer, &first, &.{"checkbox.border"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"debugIcon.breakpointForeground"}, p.red(0));
    try colorEntries(writer, &first, &.{"diffEditor.insertedTextBackground"}, p.green(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"diffEditor.removedTextBackground"}, p.red(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"dropdown.border"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"dropdown.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"editor.background"}, p.background());
    try colorEntries(writer, &first, &.{"editor.findMatchBackground"}, p.blue(0).withAlpha(0x66));
    try colorEntries(writer, &first, &.{"editor.findMatchHighlightBackground"}, p.blue(0).withAlpha(0x44));
    try colorEntries(writer, &first, &.{"editor.foldBackground"}, p.blue(0).withAlpha(0x22));
    try colorEntries(writer, &first, &.{ "editor.foreground", "foreground" }, p.fg());
    try colorEntries(writer, &first, &.{"editor.hoverHighlightBackground"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"editor.lineHighlightBackground"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"editor.rangeHighlightBackground"}, p.blue(0).withAlpha(0x22));
    try colorEntries(writer, &first, &.{
        "editor.selectionBackground", "terminal.selectionBackground", "selection.background",
        "minimap.selectionHighlight",
    }, p.blue(0).withAlpha(0x33));
    try colorEntries(writer, &first, &.{
        "editor.selectionHighlightBackground", "editor.symbolHighlightBackground",
        "editor.wordHighlightBackground",      "editor.wordHighlightStrongBackground",
    }, p.greyscale(3));
    try colorEntries(writer, &first, &.{"editorCursor.foreground"}, p.brightFg());
    try colorEntries(writer, &first, &.{"editorError.foreground"}, p.red(0));
    try colorEntries(writer, &first, &.{"editorGroup.dropBackground"}, p.blue(0).withAlpha(0x22));
    try colorEntries(writer, &first, &.{"editorGroupHeader.noTabsBackground"}, p.surface(1));
    try colorEntries(writer, &first, &.{"editorGroupHeader.tabsBackground"}, p.surface(-2));
    try colorEntries(writer, &first, &.{"editorGroup.border"}, p.greyscale(3));
    try colorEntries(writer, &first, &.{ "editorGutter.addedBackground", "minimapGutter.addedBackground" }, p.green(-1));
    try colorEntries(writer, &first, &.{"editorGutter.background"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{ "editorGutter.deletedBackground", "minimapGutter.deletedBackground" }, p.red(-1));
    try colorEntries(writer, &first, &.{ "editorGutter.modifiedBackground", "minimapGutter.modifiedBackground" }, p.yellow(-1));
    try colorEntries(writer, &first, &.{ "editorIndentGuide.activeBackground", "editorIndentGuide.activeBackground1" }, p.greyscale(3));
    try colorEntries(writer, &first, &.{ "editorIndentGuide.background", "editorIndentGuide.background1" }, p.greyscale(2));
    try colorEntries(writer, &first, &.{"editorInfo.foreground"}, p.blue(0));
    try colorEntries(writer, &first, &.{"editorLightBulb.foreground"}, p.yellow(2));
    try colorEntries(writer, &first, &.{"editorLineNumber.activeForeground"}, p.greyscale(5));
    try colorEntries(writer, &first, &.{"editorLineNumber.foreground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{ "editorLink.activeForeground", "textLink.foreground", "textLink.activeForeground" }, p.blue(0));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.addedForeground"}, p.green(0));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.border"}, p.greyscale(3));
    try colorEntries(writer, &first, &.{ "editorOverviewRuler.deletedForeground", "editorOverviewRuler.errorForeground" }, p.red(0));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.findMatchForeground"}, p.blue(0).withAlpha(0x88));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.infoForeground"}, p.blue(0));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.modifiedForeground"}, p.yellow(0));
    try colorEntries(writer, &first, &.{"editorOverviewRuler.rangeHighlightForeground"}, p.blue(0).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"editorWarning.foreground"}, p.orange(0));
    try colorEntries(writer, &first, &.{"editorWidget.background"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"editorWidget.border"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"errorLens.errorBackground"}, p.red(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"errorLens.errorForeground"}, p.red(1));
    try colorEntries(writer, &first, &.{"errorLens.warningBackground"}, p.orange(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"errorLens.warningForeground"}, p.orange(1));
    try colorEntries(writer, &first, &.{"errorLens.infoBackground"}, p.blue(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"errorLens.infoForeground"}, p.blue(1));
    try colorEntries(writer, &first, &.{"errorLens.hintBackground"}, p.green(-2).withAlpha(0x33));
    try colorEntries(writer, &first, &.{"errorLens.hintForeground"}, p.green(1));
    try colorEntries(writer, &first, &.{"focusBorder"}, p.greyscale(3));
    try colorEntries(writer, &first, &.{"gitDecoration.ignoredResourceForeground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"gitDecoration.modifiedResourceForeground"}, p.yellow(1));
    try colorEntries(writer, &first, &.{"gitDecoration.untrackedResourceForeground"}, p.green(1));
    try colorEntries(writer, &first, &.{"input.background"}, p.surface(-2));
    try colorEntries(writer, &first, &.{"input.border"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"input.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"input.placeholderForeground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"list.activeSelectionBackground"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"list.activeSelectionForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"list.errorForeground"}, p.red(0));
    try colorEntries(writer, &first, &.{"list.focusBackground"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"list.highlightForeground"}, p.blue(2));
    try colorEntries(writer, &first, &.{"list.hoverBackground"}, p.surface(0));
    try colorEntries(writer, &first, &.{"list.inactiveSelectionBackground"}, p.surface(1));
    try colorEntries(writer, &first, &.{"list.warningForeground"}, p.orange(0));
    try colorEntries(writer, &first, &.{"minimap.errorHighlight"}, p.red(0));
    try colorEntries(writer, &first, &.{"minimap.findMatchHighlight"}, p.blue(0).withAlpha(0x66));
    try colorEntries(writer, &first, &.{"minimap.warningHighlight"}, p.orange(0));
    try colorEntries(writer, &first, &.{"panel.background"}, p.surface(1));
    try colorEntries(writer, &first, &.{"panel.border"}, p.greyscale(3));
    try colorEntries(writer, &first, &.{"panelTitle.activeForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"peekView.border"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"peekViewEditor.background"}, p.background());
    try colorEntries(writer, &first, &.{"peekViewEditor.matchHighlightBackground"}, p.blue(0).withAlpha(0x66));
    try colorEntries(writer, &first, &.{"peekViewResult.background"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"peekViewResult.fileForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"peekViewResult.lineForeground"}, p.fg().withAlpha(0x99));
    try colorEntries(writer, &first, &.{"peekViewResult.matchHighlightBackground"}, p.blue(0).withAlpha(0x44));
    try colorEntries(writer, &first, &.{"peekViewResult.selectionBackground"}, p.greyscale(2));
    try colorEntries(writer, &first, &.{"peekViewResult.selectionForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"peekViewTitle.background"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"peekViewTitleDescription.foreground"}, p.blue(0));
    try colorEntries(writer, &first, &.{"peekViewTitleLabel.foreground"}, p.brightFg());
    try colorEntries(writer, &first, &.{"progressBar.background"}, p.blue(0));
    try colorEntries(writer, &first, &.{"editorInlayHint.background"}, palette.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
    try colorEntries(writer, &first, &.{"editorInlayHint.foreground"}, p.greyscale(5));
    try colorEntries(writer, &first, &.{"scrollbar.shadow"}, palette.Color{ .r = 0, .g = 0, .b = 0, .a = 0x88 });
    try colorEntries(writer, &first, &.{"settings.headerForeground"}, p.brightFg());
    try colorEntries(writer, &first, &.{"settings.modifiedItemIndicator"}, p.blue(0));
    try colorEntries(writer, &first, &.{"sideBar.background"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"sideBar.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"sideBarTitle.foreground"}, p.brightFg());
    try colorEntries(writer, &first, &.{ "statusBar.background", "statusBar.debuggingBackground", "statusBar.noFolderBackground" }, p.surface(-2));
    try colorEntries(writer, &first, &.{"statusBar.foreground"}, p.green(-1));
    try colorEntries(writer, &first, &.{"statusBar.debuggingForeground"}, p.orange(-1));
    try colorEntries(writer, &first, &.{"symbolIcon.keywordForeground"}, p.keywords());
    try colorEntries(writer, &first, &.{"symbolIcon.variableForeground"}, p.variables());
    try colorEntries(writer, &first, &.{ "symbolIcon.functionForeground", "symbolIcon.methodForeground" }, p.functions());
    try colorEntries(writer, &first, &.{
        "symbolIcon.classForeground",         "symbolIcon.structForeground", "symbolIcon.enumeratorForeground",
        "symbolIcon.typeParameterForeground",
    }, p.types());
    try colorEntries(writer, &first, &.{"symbolIcon.interfaceForeground"}, p.interfaces());
    try colorEntries(writer, &first, &.{"symbolIcon.constantForeground"}, p.constants());
    try colorEntries(writer, &first, &.{"symbolIcon.enumeratorMemberForeground"}, p.enumMembers());
    try colorEntries(writer, &first, &.{ "symbolIcon.fieldForeground", "symbolIcon.propertyForeground" }, p.properties());
    try colorEntries(writer, &first, &.{ "symbolIcon.moduleForeground", "symbolIcon.namespaceForeground" }, p.namespaces());
    try colorEntries(writer, &first, &.{"tab.activeForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"tab.border"}, p.greyscale(0));
    try colorEntries(writer, &first, &.{"tab.inactiveBackground"}, p.surface(-2));
    try colorEntries(writer, &first, &.{"tab.inactiveForeground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"terminal.ansiBlack"}, p.surface(-2));
    try colorEntries(writer, &first, &.{"terminal.ansiBlue"}, p.blue(-1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightBlack"}, p.greyscale(5));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightBlue"}, p.blue(1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightCyan"}, p.cyan(1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightGreen"}, p.green(1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightMagenta"}, p.purple(1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightRed"}, p.red(1));
    try colorEntries(writer, &first, &.{"terminal.ansiBrightWhite"}, p.brightFg());
    try colorEntries(writer, &first, &.{"terminal.ansiBrightYellow"}, p.yellow(1));
    try colorEntries(writer, &first, &.{"terminal.ansiCyan"}, p.cyan(-1));
    try colorEntries(writer, &first, &.{"terminal.ansiGreen"}, p.green(-1));
    try colorEntries(writer, &first, &.{"terminal.ansiMagenta"}, p.purple(-1));
    try colorEntries(writer, &first, &.{"terminal.ansiRed"}, p.red(-1));
    try colorEntries(writer, &first, &.{"terminal.ansiWhite"}, p.fg());
    try colorEntries(writer, &first, &.{"terminal.ansiYellow"}, p.yellow(-1));
    try colorEntries(writer, &first, &.{"terminal.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"terminalCursor.foreground"}, p.brightFg());
    try colorEntries(writer, &first, &.{"textPreformat.foreground"}, p.fg());
    try colorEntries(writer, &first, &.{"titleBar.activeBackground"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"titleBar.activeForeground"}, p.fg());
    try colorEntries(writer, &first, &.{"titleBar.inactiveBackground"}, p.surface(-1));
    try colorEntries(writer, &first, &.{"titleBar.inactiveForeground"}, p.greyscale(4));
    try colorEntries(writer, &first, &.{"widget.shadow"}, palette.Color{ .r = 0, .g = 0, .b = 0, .a = 0x88 });
}

fn colorEntries(writer: *std.Io.Writer, first: *bool, keys: []const []const u8, color: palette.Color) !void {
    for (keys) |key| {
        if (!first.*) try writer.writeAll(",\n");
        first.* = false;
        try writer.writeAll("    ");
        try writeJsonString(writer, key);
        try writer.writeAll(": ");
        try writeColorString(writer, color);
    }
}

fn writeColorString(writer: *std.Io.Writer, color: palette.Color) !void {
    const hex = "0123456789ABCDEF";
    try writer.writeAll("\"#");
    inline for (.{ color.r, color.g, color.b }) |byte| {
        try writer.writeByte(hex[byte >> 4]);
        try writer.writeByte(hex[byte & 0x0f]);
    }
    if (color.a != 0xff) {
        try writer.writeByte(hex[color.a >> 4]);
        try writer.writeByte(hex[color.a & 0x0f]);
    }
    try writer.writeByte('"');
}

fn writeJsonString(writer: *std.Io.Writer, value: []const u8) !void {
    return writeJsonStringWithSuffix(writer, value, "");
}

fn writeJsonStringWithSuffix(writer: *std.Io.Writer, value: []const u8, suffix: []const u8) !void {
    try writer.writeByte('"');
    for (value) |byte| switch (byte) {
        '"', '\\' => {
            try writer.writeByte('\\');
            try writer.writeByte(byte);
        },
        '\n' => try writer.writeAll("\\n"),
        '\r' => try writer.writeAll("\\r"),
        '\t' => try writer.writeAll("\\t"),
        else => try writer.writeByte(byte),
    };
    try writer.writeAll(suffix);
    try writer.writeByte('"');
}

fn fontStyleString(style: FontStyle) []const u8 {
    return switch (style) {
        .none, .clear => "",
        .bold => "bold",
        .italic => "italic",
        .underline => "underline",
    };
}

test "VS Code output has workbench, TextMate, and semantic colors" {
    const allocator = std.testing.allocator;
    const output = try render(allocator, palette.variants[0]);
    defer allocator.free(output);
    try std.testing.expect(std.mem.indexOf(u8, output, "\"editor.background\": \"#404040\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "\"semanticTokenColors\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "\"keyword.injected\"") != null);
}
