const std = @import("std");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 0xff,

    pub fn withAlpha(self: Color, alpha: u8) Color {
        var result = self;
        result.a = alpha;
        return result;
    }
};

pub const Palette = struct {
    base_foreground_lightness: f64,
    foreground_chroma: f64,
    base_greyscale_lightness: f64,
    greyscale_lightness_scale_multiplier: f64,
    base_color_lightness: f64,
    color_lightness_scale_multiplier: f64,
    color_chroma: f64,
    black_surfaces: bool = false,

    pub fn background(self: Palette) Color {
        return if (self.black_surfaces) .{ .r = 0, .g = 0, .b = 0 } else self.greyscale(0);
    }

    pub fn surface(self: Palette, level: i8) Color {
        return if (self.black_surfaces and level <= 1)
            .{ .r = 0, .g = 0, .b = 0 }
        else
            self.greyscale(level);
    }

    pub fn fg(self: Palette) Color {
        return oklch(self.base_foreground_lightness, self.foreground_chroma, 107.0);
    }

    pub fn brightFg(self: Palette) Color {
        return oklch(@min(self.base_foreground_lightness + 0.09, 0.99), self.foreground_chroma, 107.0);
    }

    pub fn keywords(self: Palette) Color {
        return self.yellow(2);
    }

    pub fn variables(self: Palette) Color {
        return self.fg();
    }

    pub fn functions(self: Palette) Color {
        return self.cyan(1);
    }

    pub fn types(self: Palette) Color {
        return self.cyan(-1);
    }

    pub fn interfaces(self: Palette) Color {
        return self.cyan(0);
    }

    pub fn constants(self: Palette) Color {
        return self.blue(2);
    }

    pub fn enumMembers(self: Palette) Color {
        return self.blue(2);
    }

    pub fn properties(self: Palette) Color {
        return self.orange(0);
    }

    pub fn namespaces(self: Palette) Color {
        return self.green(2);
    }

    pub fn greyscale(self: Palette, level: i8) Color {
        const lightness = switch (level) {
            -3 => self.base_greyscale_lightness - 0.2 * self.greyscale_lightness_scale_multiplier,
            -2 => self.base_greyscale_lightness - 0.07 * self.greyscale_lightness_scale_multiplier,
            -1 => self.base_greyscale_lightness - 0.025 * self.greyscale_lightness_scale_multiplier,
            0 => self.base_greyscale_lightness,
            1 => self.base_greyscale_lightness + 0.03 * self.greyscale_lightness_scale_multiplier,
            2 => self.base_greyscale_lightness + 0.06 * self.greyscale_lightness_scale_multiplier,
            3 => self.base_greyscale_lightness + 0.13 * self.greyscale_lightness_scale_multiplier,
            4 => self.base_greyscale_lightness + 0.18 * self.greyscale_lightness_scale_multiplier,
            5 => self.base_greyscale_lightness + 0.33 * self.greyscale_lightness_scale_multiplier,
            else => unreachable,
        };
        return oklch(lightness, 0.0, 0.0);
    }

    pub fn red(self: Palette, level: i8) Color {
        return self.color(19.0, level, null);
    }

    pub fn orange(self: Palette, level: i8) Color {
        return self.color(55.0, level, null);
    }

    pub fn yellow(self: Palette, level: i8) Color {
        return self.color(97.0, level, null);
    }

    pub fn green(self: Palette, level: i8) Color {
        return self.color(145.0, level, null);
    }

    pub fn cyan(self: Palette, level: i8) Color {
        return self.color(200.0, level, null);
    }

    pub fn purple(self: Palette, level: i8) Color {
        return self.color(300.0, level, null);
    }

    pub fn blue(self: Palette, level: i8) Color {
        const chroma = if (level == 2) @min(self.color_chroma, 0.045) else self.color_chroma;
        return self.color(243.0, level, chroma);
    }

    fn color(self: Palette, hue: f64, level: i8, chroma_override: ?f64) Color {
        const lightness = switch (level) {
            -2 => self.base_color_lightness - 0.15 * self.color_lightness_scale_multiplier,
            -1 => self.base_color_lightness - 0.05 * self.color_lightness_scale_multiplier,
            0 => self.base_color_lightness,
            1 => self.base_color_lightness + 0.05 * self.color_lightness_scale_multiplier,
            2 => self.base_color_lightness + 0.1 * self.color_lightness_scale_multiplier,
            else => unreachable,
        };
        return oklch(lightness, chroma_override orelse self.color_chroma, hue);
    }
};

pub const Variant = struct {
    slug: []const u8,
    label: []const u8,
    vscode_file: []const u8,
    ghostty_file: []const u8,
    palette: Palette,
};

pub const variants = [_]Variant{
    .{
        .slug = "original",
        .label = "Pale Fire 01 - Original",
        .vscode_file = "pale-fire-color-theme.json",
        .ghostty_file = "Pale Fire 01 - Original",
        .palette = .{
            .base_foreground_lightness = 0.9,
            .foreground_chroma = 0.03,
            .base_greyscale_lightness = 0.37,
            .greyscale_lightness_scale_multiplier = 1.0,
            .base_color_lightness = 0.8,
            .color_lightness_scale_multiplier = 1.0,
            .color_chroma = 0.064,
        },
    },
    .{
        .slug = "high-contrast",
        .label = "Pale Fire 02 - High Contrast",
        .vscode_file = "pale-fire-high-contrast-color-theme.json",
        .ghostty_file = "Pale Fire 02 - High Contrast",
        .palette = .{
            .base_foreground_lightness = 0.93,
            .foreground_chroma = 0.03,
            .base_greyscale_lightness = 0.34,
            .greyscale_lightness_scale_multiplier = 1.5,
            .base_color_lightness = 0.8,
            .color_lightness_scale_multiplier = 1.15,
            .color_chroma = 0.078,
        },
    },
    .{
        .slug = "stealth",
        .label = "Pale Fire 03 - Stealth",
        .vscode_file = "pale-fire-stealth-color-theme.json",
        .ghostty_file = "Pale Fire 03 - Stealth",
        .palette = .{
            .base_foreground_lightness = 0.9,
            .foreground_chroma = 0.03,
            .base_greyscale_lightness = 0.27,
            .greyscale_lightness_scale_multiplier = 0.5,
            .base_color_lightness = 0.75,
            .color_lightness_scale_multiplier = 0.8,
            .color_chroma = 0.064,
        },
    },
    .{
        .slug = "darker",
        .label = "Pale Fire 04 - Darker",
        .vscode_file = "pale-fire-darker-color-theme.json",
        .ghostty_file = "Pale Fire 04 - Darker",
        .palette = .{
            .base_foreground_lightness = 0.95,
            .foreground_chroma = 0.01,
            .base_greyscale_lightness = 0.2,
            .greyscale_lightness_scale_multiplier = 0.9,
            .base_color_lightness = 0.75,
            .color_lightness_scale_multiplier = 1.05,
            .color_chroma = 0.1,
        },
    },
    .{
        .slug = "deep-dark",
        .label = "Pale Fire 05 - Deep Dark",
        .vscode_file = "pale-fire-deep-dark-color-theme.json",
        .ghostty_file = "Pale Fire 05 - Deep Dark",
        .palette = .{
            .base_foreground_lightness = 0.95,
            .foreground_chroma = 0.01,
            .base_greyscale_lightness = 0.165,
            .greyscale_lightness_scale_multiplier = 0.8,
            .base_color_lightness = 0.75,
            .color_lightness_scale_multiplier = 1.05,
            .color_chroma = 0.1,
        },
    },
    .{
        .slug = "near-black",
        .label = "Pale Fire 06 - Near Black",
        .vscode_file = "pale-fire-near-black-color-theme.json",
        .ghostty_file = "Pale Fire 06 - Near Black",
        .palette = .{
            .base_foreground_lightness = 0.95,
            .foreground_chroma = 0.01,
            .base_greyscale_lightness = 0.13,
            .greyscale_lightness_scale_multiplier = 0.7,
            .base_color_lightness = 0.75,
            .color_lightness_scale_multiplier = 1.05,
            .color_chroma = 0.1,
        },
    },
    .{
        .slug = "full-black",
        .label = "Pale Fire 07 - Full Black",
        .vscode_file = "pale-fire-full-black-color-theme.json",
        .ghostty_file = "Pale Fire 07 - Full Black",
        .palette = .{
            .base_foreground_lightness = 0.95,
            .foreground_chroma = 0.01,
            .base_greyscale_lightness = 0.13,
            .greyscale_lightness_scale_multiplier = 0.7,
            .base_color_lightness = 0.75,
            .color_lightness_scale_multiplier = 1.05,
            .color_chroma = 0.1,
            .black_surfaces = true,
        },
    },
};

pub fn findVariant(slug: []const u8) ?Variant {
    for (variants) |variant| {
        if (std.mem.eql(u8, slug, variant.slug)) return variant;
    }
    return null;
}

fn oklch(lightness_unclamped: f64, chroma: f64, hue_degrees: f64) Color {
    const lightness = std.math.clamp(lightness_unclamped, 0.0, 1.0);
    const hue = std.math.degreesToRadians(hue_degrees);
    const lab_a = chroma * @cos(hue);
    const lab_b = chroma * @sin(hue);

    const l_root = lightness + 0.3963377774 * lab_a + 0.2158037573 * lab_b;
    const m_root = lightness - 0.1055613458 * lab_a - 0.0638541728 * lab_b;
    const s_root = lightness - 0.0894841775 * lab_a - 1.2914855480 * lab_b;

    const l = l_root * l_root * l_root;
    const m = m_root * m_root * m_root;
    const s = s_root * s_root * s_root;

    return .{
        .r = srgbByte(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
        .g = srgbByte(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
        .b = srgbByte(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
    };
}

fn srgbByte(linear: f64) u8 {
    const encoded = if (linear <= 0.0031308)
        12.92 * linear
    else
        1.055 * std.math.pow(f64, linear, 1.0 / 2.4) - 0.055;
    const clamped = std.math.clamp(encoded, 0.0, 1.0);
    return @intFromFloat(@round(clamped * 255.0));
}

test "original palette remains compatible with Pale Fire" {
    const original = variants[0].palette;
    try std.testing.expectEqual(Color{ .r = 0xe0, .g = 0xe0, .b = 0xc9 }, original.fg());
    try std.testing.expectEqual(Color{ .r = 0x40, .g = 0x40, .b = 0x40 }, original.greyscale(0));
    try std.testing.expectEqual(Color{ .r = 0x9a, .g = 0xc3, .b = 0xe4 }, original.blue(0));
}

test "full black palette has a true black base" {
    const full_black = findVariant("full-black").?;
    try std.testing.expectEqual(Color{ .r = 0, .g = 0, .b = 0 }, full_black.palette.background());
    try std.testing.expect(full_black.palette.greyscale(3).r > 0);
}
