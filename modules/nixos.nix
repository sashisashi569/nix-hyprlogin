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
  };

  config = lib.mkIf cfg.enable {
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
