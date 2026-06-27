# nix-hyprlogin

Nix flake that packages [hyprlogin](https://github.com/AuthenticSm1les/hyprlogin) — a GPU-accelerated [greetd](https://git.sr.ht/~kennylevinsen/greetd) greeter for Hyprland, forked from hyprlock.

## How it works

greetd launches a temporary Hyprland session, which runs hyprlogin via `exec-once`. hyprlogin presents the login screen using the `ext-session-lock-v1` Wayland protocol. On successful authentication, it communicates with greetd over `GREETD_SOCK`, exits Hyprland via `hyprctl dispatch exit`, and greetd starts the user's selected session.

## Usage

### NixOS module (recommended)

Add this flake to your system flake and import the NixOS module:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-hyprlogin.url = "github:sashisashi569/nix-hyprlogin";
  };

  outputs = { nixpkgs, nix-hyprlogin, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nix-hyprlogin.nixosModules.default
        {
          nixpkgs.overlays = [ nix-hyprlogin.overlays.default ];

          services.hyprlogin = {
            enable = true;
            kbLayout = "jp";
          };
        }
      ];
    };
  };
}
```

The module automatically:
- Configures greetd to start a minimal Hyprland greeter session
- Passes the correct session file paths for NixOS (`/run/current-system/sw/share/wayland-sessions`)
- Creates the `greeter` user

### Module options

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | bool | `false` | Enable the hyprlogin greeter |
| `package` | package | `pkgs.hyprlogin` | hyprlogin package to use |
| `hyprlandPackage` | package | `pkgs.hyprland` | Hyprland package for the greeter session |
| `kbLayout` | string | `"us"` | Keyboard layout for the greeter session |
| `extraHyprlandConfig` | lines | `""` | Extra lines appended to the greeter Hyprland config |
| `extraHyprloginConfig` | lines | `""` | Extra lines appended to the hyprlogin config |

### Customizing the hyprlogin config

The generated config sources the example config shipped with hyprlogin and then applies NixOS-specific overrides. Use `extraHyprloginConfig` to add your own settings on top:

```nix
services.hyprlogin = {
  enable = true;
  kbLayout = "jp";
  extraHyprloginConfig = ''
    sessions {
      default_user = alice
      default_session = hyprland.desktop
    }
  '';
};
```

### Overlay only

If you prefer to manage greetd yourself, you can use just the overlay to get `pkgs.hyprlogin`:

```nix
nixpkgs.overlays = [ inputs.nix-hyprlogin.overlays.default ];

services.greetd = {
  enable = true;
  settings.default_session = {
    command = "Hyprland --config /path/to/your/hyprland-greeter.conf";
    user = "greeter";
  };
};
```

Your `hyprland-greeter.conf` should contain:

```ini
exec-once = hyprlogin -c /path/to/hyprlogin.conf
monitor = ,preferred,auto,1
```

And your `hyprlogin.conf` should set the session paths for NixOS:

```ini
sessions {
  wayland_path = /run/current-system/sw/share/wayland-sessions
  x11_path = /run/current-system/sw/share/xsessions
}
```

## Version pinning

The hyprlogin source is pinned in `flake.lock`. Run `nix flake update` to update to the latest commit. The Hyprland version used in the greeter session follows your system's nixpkgs, not this flake's lock file.

## License

The Nix packaging in this repository is released under the MIT License. hyprlogin itself is licensed under the BSD 3-Clause License.
