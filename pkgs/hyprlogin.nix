{
  lib,
  gcc15Stdenv,
  src,
  cmake,
  pkg-config,
  libGL,
  libxkbcommon,
  hyprgraphics,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  pam,
  sdbus-cpp_2,
  systemdLibs,
  wayland,
  wayland-protocols,
  wayland-scanner,
  cairo,
  file,
  libjpeg,
  libwebp,
  pango,
  libdrm,
  libgbm,
}:

gcc15Stdenv.mkDerivation {
  pname = "hyprlogin";
  version = "0.1.0";

  inherit src;

  nativeBuildInputs = [
    cmake
    pkg-config
    hyprwayland-scanner
    wayland-scanner
  ];

  buildInputs = [
    cairo
    file
    hyprgraphics
    hyprlang
    hyprutils
    libdrm
    libGL
    libjpeg
    libwebp
    libxkbcommon
    libgbm
    pam
    pango
    sdbus-cpp_2
    systemdLibs
    wayland
    wayland-protocols
  ];

  meta = {
    description = "GPU-accelerated greetd greeter for Hyprland, a hyprlock fork";
    homepage = "https://github.com/AuthenticSm1les/hyprlogin";
    license = lib.licenses.bsd3;
    mainProgram = "hyprlogin";
    platforms = lib.platforms.linux;
  };
}
