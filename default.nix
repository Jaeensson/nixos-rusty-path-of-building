{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  luajitPackages,
  luajit,
  wayland,
  libxkbcommon,
  xorg,
  vulkan-loader,
  libGL,
  zlib,
  makeDesktopItem,
  pkgs
}:
let
  # Lua modules to use at runtime
  luaModules = [
    luajitPackages.lua-curl
    luajitPackages.luautf8
    luajitPackages.luasocket
  ];

  mkLuaEnv = luaPkgs: {
    LUA_PATH = lib.concatStringsSep ";" (map (p: "${p}/share/lua/5.1/?.lua;${p}/share/lua/5.1/?/init.lua") luaPkgs);
    LUA_CPATH = lib.concatStringsSep ";" (map (p: "${p}/lib/lua/5.1/?.so") luaPkgs);
  };

  luaEnv = mkLuaEnv luaModules;

  # upstream GitHub source
  srcGitHub = fetchFromGitHub {
    owner = "meehl";
    repo = "rusty-path-of-building";
    rev = "v0.2.6";
    hash = "sha256-U2OWNV8bUNXo8/Sro+gV/o3O/D1lMWVlbX3tCONmGOk=";
  };

  # your local folder containing icons
  srcIcons = ./icons;

  # combined source
  src = pkgs.runCommand "rusty-path-of-building-src" {
    inherit srcGitHub srcIcons;
  } ''
    mkdir -p $out/icons
    cp -r $srcGitHub/* $out/
    cp $srcIcons/pob.png  $out/icons/pob.png
    cp $srcIcons/pob2.png $out/icons/pob2.png
  '';

in
rustPlatform.buildRustPackage rec {
  pname = "rusty-path-of-building";
  version = "0.2.6";

  inherit src;

  cargoHash = "sha256-xB7nhCqUalGE0M762Zw7vVFKzz/TgnMU77xbEHorJ2U=";
  cargoLock = { lockFile = ./Cargo.lock; };

  nativeBuildInputs = [ pkg-config makeWrapper ];

  # Build & runtime dependencies
  buildInputs = [
    luajit
    wayland
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    vulkan-loader
    libGL
    zlib
  ] ++ luaModules;

  preBuild = ''
    # Build lzip
    mkdir -p $out/lib/lua/5.1
    pushd lua/libs/lzip/src
    g++ -O2 -shared -fPIC -o $out/lib/lua/5.1/lzip.so lzip.cpp $(pkg-config --libs zlib)
    popd
  '';
  
  postBuild = ''
    # Use cargo install to put binary into $out
    cargo install --locked --path . --root $out --force
  '';

  # Wrap binary with LuaJIT paths, LD_LIBRARY_PATH, and Wayland/X11 detection
  postFixup = ''
    for exe in $out/bin/*; do
      if [ -f "$exe" ] && [ -x "$exe" ]; then
        echo "Wrapping $exe"
        wrapProgram "$exe" \
          --run 'if [ -n "$WAYLAND_DISPLAY" ]; then
                  echo "💡 Detected Wayland session"
                  export GDK_BACKEND=wayland
                  export WINIT_UNIX_BACKEND=wayland
              else
                  echo "💡 Detected X11 session"
                  export GDK_BACKEND=x11
                  export WINIT_UNIX_BACKEND=x11
              fi' \
          --set-default WGPU_BACKEND "gl" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
          --set LUA_PATH "${luaEnv.LUA_PATH}" \
          --set LUA_CPATH "${luaEnv.LUA_CPATH};$out/lib/lua/5.1/?.so"
      fi
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "rusty-path-of-building";
      desktopName = "Path of Building";
      comment = "Offline build planner for Path of Exile";
      exec = "rusty-path-of-building poe1 %U";
      terminal = false;
      type = "Application";
      icon = "pob";
      categories = [ "Game" ];
      keywords = [
        "poe"
        "pob"
        "pobc"
        "path"
        "exile"
      ];
      mimeTypes = [ "x-scheme-handler/pob" ];
    })

    (makeDesktopItem {
      name = "rusty-path-of-building2";
      desktopName = "Path of Building 2";
      comment = "Offline build planner for Path of Exile 2";
      exec = "rusty-path-of-building poe2 %U";
      terminal = false;
      type = "Application";
      icon = "pob2";
      categories = [ "Game" ];
      keywords = [
        "poe"
        "pob"
        "pobc"
        "path"
        "exile"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    # Install icons
    mkdir -p $out/share/icons/hicolor/128x128/apps
    install -Dm644 $src/icons/pob.png  $out/share/icons/hicolor/128x128/apps/pob.png
    install -Dm644 $src/icons/pob2.png $out/share/icons/hicolor/128x128/apps/pob2.png

    # Install desktop entries
    mkdir -p $out/share/applications
    for item in ${toString (map (x: "${x}/share/applications" ) desktopItems)}; do
      cp "$item"/* $out/share/applications/
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Rust-based Path of Building fork";
    homepage = "https://github.com/meehl/rusty-path-of-building/";
    license = licenses.mit;
    mainProgram = "rusty-path-of-building";
    platforms = platforms.linux;
  };
}
