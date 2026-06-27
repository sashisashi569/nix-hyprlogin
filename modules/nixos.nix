{ config, lib, pkgs, ... }:

let
  cfg = config.services.hyprlogin;
in {
  options.services.hyprlogin = {
    enable = lib.mkEnableOption "hyprlogin greetd greeter";

    package = lib.mkPackageOption pkgs "hyprlogin" {};

    hyprlandPackage = lib.mkPackageOption pkgs "hyprland" {
      default = [ "hyprland" ];
    };

    kbLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Keyboard layout for the greeter session.";
    };

    extraHyprlandConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended to the greeter Hyprland config.";
    };

    extraHyprloginConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended to the generated hyprlogin config.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command =
          let
            # NixOS のセッションファイルは /run/current-system/sw/share 以下。
            # /etc/hyprlogin/hyprlogin.conf への依存を避け、-c で Nix store 内の
            # 設定ファイルを直接渡すことで確実に設定が反映される。
            hyprloginConf = pkgs.writeText "hyprlogin.conf" ''
              source = ${cfg.package}/share/hyprlogin/examples/hyprlogin.conf
              general {
                exit_command = ${cfg.hyprlandPackage}/bin/hyprctl dispatch exit
              }
              sessions {
                wayland_path = /run/current-system/sw/share/wayland-sessions
                x11_path = /run/current-system/sw/share/xsessions
              }
              ${cfg.extraHyprloginConfig}
            '';
            hyprlandGreeterConf = pkgs.writeText "hyprland-greeter.conf" ''
              exec-once = ${cfg.package}/bin/hyprlogin -c ${hyprloginConf}
              monitor = ,preferred,auto,1
              input {
                kb_layout = ${cfg.kbLayout}
              }
              ${cfg.extraHyprlandConfig}
            '';
          in
          "${cfg.hyprlandPackage}/bin/Hyprland --config ${hyprlandGreeterConf}";
        user = "greeter";
      };
    };

    environment.systemPackages = [ cfg.hyprlandPackage ];

    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };
    users.groups.greeter = {};
  };
}
