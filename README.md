# Pale Fire Variants

A small, self-contained Zig theme generator based on [matklad's Pale Fire](https://github.com/matklad/pale-fire), which is itself based on [Zenburn for Emacs](https://github.com/bbatsov/zenburn-emacs). The Near Black and Full Black variants were inspired by [Dark+ (Full Black)](https://github.com/DhruvDh/dark-plus-full-black).

The goal is simple: keep a reusable color engine in one place, then output Pale Fire everywhere else. The palette and OKLCH conversion are the core; VS Code and Ghostty are small backends. Adding another target should only require mapping the core colors into that target's format.

## Variants

| Variant | VS Code editor background | Character |
| --- | --- | --- |
| Pale Fire 01 - Original | `#404040` | The original palette |
| Pale Fire 02 - High Contrast | `#383838` | Stronger contrast |
| Pale Fire 03 - Stealth | `#262626` | Muted contrast |
| Pale Fire 04 - Darker | `#161616` | Upstream's darker variant |
| Pale Fire 05 - Deep Dark | `#0E0E0E` | Between Darker and Near Black |
| Pale Fire 06 - Near Black | `#070707` | Almost black with subtle depth |
| Pale Fire 07 - Full Black | `#000000` | Black primary surfaces with visible borders |

Every variant is generated for both VS Code and Ghostty under `themes/`. Generated themes and VSIX packages are intentionally not committed; the Zig source is the source of truth.

## Generate

With `direnv allow`, the Nix development shell provides Zig, Node.js, and `jq`. You can also enter it directly with `nix develop`.

```sh
zig build run -- generate
zig build run -- check
zig build test
```

List variants with `zig build run -- list`, or generate one with `zig build run -- generate --variant near-black`.

## VS Code

The theme registration is the `contributes.themes` section in [`package.json`](./package.json); a theme-only extension needs no runtime extension code.

Build and install a local VSIX:

```sh
npm install
npm run package:vscode
code --install-extension pale-fire-variants-0.1.0.vsix
```

The VS Code packager runs the Zig generator automatically before building the VSIX.

Then choose a Pale Fire variant from **Preferences: Color Theme**.

To publish, first create a VS Code Marketplace publisher whose ID matches the `publisher` field in `package.json`, then follow the [official publishing guide](https://code.visualstudio.com/api/working-with-extensions/publishing-extension) and run `npm run publish:vscode`.

## Ghostty

Copy the generated files into Ghostty's user theme directory:

```sh
zig build run -- generate
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes"
cp themes/ghostty/* "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/"
```

Then select one in the Ghostty configuration, for example:

```ini
theme = Pale Fire 06 - Near Black
```

## Adding a backend

Use [`src/palette.zig`](./src/palette.zig) as the color engine, add a renderer beside [`src/ghostty.zig`](./src/ghostty.zig) and [`src/vscode.zig`](./src/vscode.zig), then call it from the generation loop in [`src/main.zig`](./src/main.zig). Backends should contain formatting and target-specific mappings, not independent palettes.

## License

GPLv3, like [the original Pale Fire](https://github.com/matklad/pale-fire). See [`LICENSE`](./LICENSE).
