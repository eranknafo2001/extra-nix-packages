{
  pkgs,
  lib,
}:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stremio-linux-shell";
  version = "v1.0.0-beta.11";

  src = pkgs.fetchFromGitHub {
    owner = "Stremio";
    repo = "stremio-linux-shell";
    tag = finalAttrs.version;
    hash = "sha256-FNAeur5esDqBoYlmjUO6jdi1eC83ynbLxbjH07QZ++E=";
  };

  cargoHash = "sha256-9/28BCG51jPnKXbbzzNp7KQLMkLEugFQfwszRR9kmUw=";

  # Let the build script handle CEF setup using our provided CEF_PATH
  # cargoFeatures = ["offline-build"];

  # Download CEF binary separately
  cefBinary = pkgs.fetchurl {
    url = "https://cef-builds.spotifycdn.com/cef_binary_137.0.2+gc91f84b+chromium-137.0.7151.6_linux64_beta_minimal.tar.bz2";
    hash = "sha256-4Ks+CMY5C085F1flwRr2hdYqybaLA74j1zSKCb9BVOI=";
  };

  preBuild = ''
    # Set up CEF path as expected by build script (offline-build feature expects CEF_PATH to be set)
    export CEF_PATH=$TMPDIR/cef
    mkdir -p $CEF_PATH

    # Extract CEF binary
    echo "Extracting CEF binary..."
    ${pkgs.gnutar}/bin/tar -xf ${finalAttrs.cefBinary} -C $TMPDIR

    # Find the extracted CEF directory (it has a version-specific name)
    CEF_EXTRACTED=$(find $TMPDIR -maxdepth 1 -name "cef_binary_*" -type d | head -1)

    if [ -n "$CEF_EXTRACTED" ]; then
      echo "Setting up CEF structure as expected by stremio..."

      # Create the structure that stremio's build script expects
      # Based on their CEF_ARCHIVE_FILES, they expect files directly in CEF_PATH
      mkdir -p $CEF_PATH/locales

      # Copy locale files
      if [ -d "$CEF_EXTRACTED/Resources/locales" ]; then
        cp -r "$CEF_EXTRACTED"/Resources/locales/* $CEF_PATH/locales/ 2>/dev/null || true
      fi

      # Copy pak files and other resources to root
      if [ -d "$CEF_EXTRACTED/Resources" ]; then
        cp "$CEF_EXTRACTED"/Resources/*.pak $CEF_PATH/ 2>/dev/null || true
        cp "$CEF_EXTRACTED"/Resources/icudtl.dat $CEF_PATH/ 2>/dev/null || true
      fi

      # Copy Release libraries to root
      if [ -d "$CEF_EXTRACTED/Release" ]; then
        cp "$CEF_EXTRACTED"/Release/libcef.so $CEF_PATH/ 2>/dev/null || true
        cp "$CEF_EXTRACTED"/Release/libEGL.so $CEF_PATH/ 2>/dev/null || true
        cp "$CEF_EXTRACTED"/Release/libGLESv2.so $CEF_PATH/ 2>/dev/null || true
        cp "$CEF_EXTRACTED"/Release/libvk_swiftshader.so $CEF_PATH/ 2>/dev/null || true
        cp "$CEF_EXTRACTED"/Release/v8_context_snapshot.bin $CEF_PATH/ 2>/dev/null || true
      fi

      # Patch CEF library with correct library paths
      if [ -f "$CEF_PATH/libcef.so" ]; then
        echo "Patching libcef.so with system dependencies..."
        patchelf --set-rpath "${pkgs.lib.makeLibraryPath [
      pkgs.xorg.libX11
      pkgs.xorg.libXrandr
      pkgs.xorg.libXi
      pkgs.xorg.libXcursor
      pkgs.xorg.libXfixes
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXdamage
      pkgs.xorg.libXcomposite
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libXtst
      pkgs.xorg.libxcb
      pkgs.libxkbcommon
      pkgs.libGL
      pkgs.mesa
      pkgs.libgbm
      pkgs.alsa-lib
      pkgs.nss
      pkgs.nspr
      pkgs.dbus
      pkgs.cups
      pkgs.zlib
      pkgs.expat
      pkgs.fontconfig
      pkgs.freetype
      pkgs.stdenv.cc.cc.lib
      pkgs.systemd
      pkgs.libdrm
      pkgs.wayland
      pkgs.libglvnd
      pkgs.libffi
      pkgs.vulkan-loader
      pkgs.libva
      pkgs.libvdpau
      pkgs.libappindicator-gtk3
      pkgs.libayatana-appindicator
    ]}" "$CEF_PATH/libcef.so"
      fi

      # Make libraries available for linking
      export LD_LIBRARY_PATH="$CEF_PATH:$LD_LIBRARY_PATH"
      export LIBRARY_PATH="$CEF_PATH:$LIBRARY_PATH"
    else
      echo "Warning: CEF extraction failed, build may fail"
    fi
  '';

  # Set environment variables needed by the build
  preConfigure = ''
    export CEF_PATH=$TMPDIR/cef
  '';

  buildInputs = with pkgs; [
    # Core GTK and system libraries
    glib
    cairo
    atk
    pango
    gtk3
    openssl
    gettext

    # Media support
    mpv # Provides libmpv

    # X11 libraries (required for CEF)
    xorg.libX11
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXext
    xorg.libXrender
    xorg.libXdamage
    xorg.libXcomposite
    xorg.libXScrnSaver
    xorg.libXtst

    # XKB support
    libxkbcommon

    # XCB libraries
    xorg.libxcb

    # Graphics and rendering
    libGL
    mesa
    libdrm

    # Audio
    alsa-lib

    # System services and security
    cups
    nss
    nspr
    dbus

    # Core system libraries
    stdenv.cc.cc.lib
    zlib
    expat
    fontconfig
    freetype

    # Additional libraries that may be needed
    at-spi2-atk
    gdk-pixbuf
    harfbuzz
    systemd

    # Windowing system support
    wayland
    wayland-protocols
    wayland-scanner
    libffi

    # EGL/OpenGL context support
    libglvnd
    egl-wayland

    # Additional X11 support
    xorg.libXScrnSaver
    xorg.libXinerama
    xorg.libXv

    # Vulkan support
    vulkan-loader
    vulkan-headers
    spirv-tools

    # Hardware acceleration
    libva
    libva-utils
    libvdpau
    vdpauinfo

    # Additional graphics support
    libepoxy

    # System tray support
    libappindicator-gtk3
    libayatana-appindicator

    # Portal and desktop integration
    xdg-desktop-portal
    xdg-desktop-portal-gtk

    # Additional system libraries for CEF and device access
    udev
    libdrm
    libgbm
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    gnutar # For extracting CEF
    makeWrapper
    autoPatchelfHook
    patchelf # For patching CEF library
  ];

  # Tell autoPatchelfHook to ignore libcef.so since we handle it manually
  autoPatchelfIgnoreMissingDeps = ["libcef.so"];

  postInstall = ''
        # Copy CEF libraries to the output directory
        if [ -n "$CEF_PATH" ] && [ -d "$CEF_PATH" ]; then
          mkdir -p $out/lib/cef
          cp -r "$CEF_PATH"/* $out/lib/cef/ 2>/dev/null || true

          # Make sure the CEF library is executable
          chmod +x $out/lib/cef/libcef.so 2>/dev/null || true

          # Create SwiftShader Vulkan ICD file
          cat > $out/lib/cef/vk_swiftshader_icd.json << EOF
    {
        "file_format_version": "1.0.0",
        "ICD": {
            "library_path": "./libvk_swiftshader.so",
            "api_version": "1.1.0"
        }
    }
    EOF
        fi
  '';

  # Skip tests for now as they might have similar dependency issues
  doCheck = false;

  postFixup = ''
    # Wrap the binary to provide runtime dependencies
    wrapProgram $out/bin/stremio-linux-shell \
      --set-default GDK_BACKEND "x11" \
      --set-default QT_QPA_PLATFORM "xcb" \
      --unset WAYLAND_DISPLAY \
      --set-default WINIT_UNIX_BACKEND "x11" \
      --set-default SDL_VIDEODRIVER "x11" \
      --add-flags "--disable-gpu-sandbox" \
      --add-flags "--disable-vulkan" \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "$out/lib/cef:${pkgs.lib.makeLibraryPath [
      pkgs.xorg.libX11
      pkgs.xorg.libXrandr
      pkgs.xorg.libXi
      pkgs.xorg.libXcursor
      pkgs.xorg.libXfixes
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXdamage
      pkgs.xorg.libXcomposite
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libXtst
      pkgs.libGL
      pkgs.mesa
      pkgs.alsa-lib
      pkgs.nss
      pkgs.dbus
      pkgs.libxkbcommon
      pkgs.cups
      pkgs.mpv
      pkgs.systemd
      pkgs.libdrm
      pkgs.libgbm
      pkgs.wayland
      pkgs.libglvnd
      pkgs.libffi
      pkgs.egl-wayland
      pkgs.vulkan-loader
      pkgs.libva
      pkgs.libvdpau
      pkgs.libepoxy
      pkgs.libappindicator-gtk3
      pkgs.libayatana-appindicator
    ]}"
  '';

  meta = {
    description = "Client for Stremio on Linux";
    homepage = "https://github.com/Stremio/stremio-linux-shell";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.linux;
  };
})
