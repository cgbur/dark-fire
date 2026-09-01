# Pale Fire Variants

Pale Fire themes for VS Code and Ghostty, generated from one small Zig color engine.

This project is based on [matklad's Pale Fire](https://github.com/matklad/pale-fire), which is itself based on [Zenburn for Emacs](https://github.com/bbatsov/zenburn-emacs). The Near Black and Full Black variants were inspired by [Dark+ (Full Black)](https://github.com/DhruvDh/dark-plus-full-black).

The palette and its variants live in one place. Each backend only maps those colors into its target format, making it straightforward to add more outputs later.

## Install

### VS Code

Download the `.vsix` file from the [latest release](https://github.com/cgbur/pale-fire/releases/latest). In VS Code, open the Command Palette, run **Extensions: Install from VSIX...**, and choose the downloaded file.

Then run **Preferences: Color Theme** and choose a Pale Fire variant. To update later, download and install the newer VSIX.

Marketplace publication is deferred and tracked in [issue #1](https://github.com/cgbur/pale-fire/issues/1).

### Ghostty

Download `pale-fire-ghostty-themes-*.zip` from the [latest release](https://github.com/cgbur/pale-fire/releases/latest) and extract it with your archive application. Copy the extracted files into Ghostty's theme directory:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes"
cp /path/to/extracted-themes/* "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/"
```

Add a theme to `${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty`:

```ini
theme = Pale Fire 06 - Near Black
```

Reload Ghostty's configuration or restart Ghostty. See the [Ghostty configuration documentation](https://ghostty.org/docs/config) for alternative config locations.

## Variants

The names sort from lightest background to darkest:

| Variant | Editor background | Character |
| --- | --- | --- |
| Pale Fire 01 - Original | `#404040` | The original palette |
| Pale Fire 02 - High Contrast | `#383838` | Stronger contrast |
| Pale Fire 03 - Stealth | `#262626` | Muted contrast |
| Pale Fire 04 - Darker | `#161616` | Upstream's darker variant |
| Pale Fire 05 - Deep Dark | `#0E0E0E` | Between Darker and Near Black |
| Pale Fire 06 - Near Black | `#070707` | Almost black with subtle depth |
| Pale Fire 07 - Full Black | `#000000` | Black primary surfaces with visible borders |

## Development

Run `direnv allow` to enter the Nix development shell automatically, or use `nix develop` directly. The shell provides Zig, Node.js, `jq`, and `zip`.

```sh
zig build run -- generate
zig build run -- check
zig build test
```

The generator writes every variant to `themes/vscode/` and `themes/ghostty/`. Generated themes and VSIX files are not committed; the Zig source is the source of truth.

List variants with `zig build run -- list`, or generate one with `zig build run -- generate --variant near-black`.

To package the VS Code themes locally:

```sh
npm ci
npm run package:vscode
```

The VS Code package is registered through `contributes.themes` in [`package.json`](./package.json) and needs no runtime extension code.

## Adding a backend

Keep palette decisions in [`src/palette.zig`](./src/palette.zig) and target-specific formatting in the backend. [`src/ghostty.zig`](./src/ghostty.zig) is the smallest example. A backend exposes:

```zig
pub fn render(allocator: std.mem.Allocator, variant: palette.Variant) ![]u8
```

The caller owns the returned buffer. Use `variant.palette` for colors and `variant.slug` or `variant.label` for names. Use `background()` and `surface()` for surfaces so the Full Black variant remains truly black.

To wire it in:

1. Import the backend in [`src/main.zig`](./src/main.zig) and create its `themes/<target>/` output directory.
2. Extend `processVariant` to render and either write or check the backend's file. Derive its filename from the slug or label, or add a field to `palette.Variant` when the target needs a special name.
3. Add a focused renderer test, then run:

```sh
zig fmt --check build.zig src
zig build test
zig build run -- generate
zig build run -- check
```

If the backend should be downloadable, also bundle `themes/<target>/` in [the release workflow](./.github/workflows/release.yml) and add its installation instructions here.

## License

GPLv3, like [the original Pale Fire](https://github.com/matklad/pale-fire). See [`LICENSE`](./LICENSE).
