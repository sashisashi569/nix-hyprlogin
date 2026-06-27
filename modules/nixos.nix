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
      description = "Extra lines appended to /etc/hyprlogin/hyprlogin.conf.";
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS のセッションファイルは /run/current-system/sw/share 以下に置かれるため
    # デフォルトの /usr/share では検出できない。/etc/hyprlogin/hyprlogin.conf で上書きする。
    environment.etc."hyprlogin/hyprlogin.conf".text = ''
      general {
        exit_command = ${cfg.hyprlandPackage}/bin/hyprctl dispatch exit
      }
      sessions {
        wayland_path = /run/current-system/sw/share/wayland-sessions
        x11_path = /run/current-system/sw/share/xsessions
      }
      ${cfg.extraHyprloginConfig}
    '';

    services.greetd = {
      enable = true;
      settings.default_session = {
        command =
          let
            hyprlandGreeterConf = pkgs.writeText "hyprland-greeter.conf" ''
              exec-once = ${cfg.package}/bin/hyprlogin
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

    # hyprlogin の exit_command で hyprctl を使うため PATH に含める
    environment.systemPackages = [ cfg.hyprlandPackage ];

    # greeter ユーザーに GPU アクセス権限を付与
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };
    users.groups.greeter = {};
  };
}
