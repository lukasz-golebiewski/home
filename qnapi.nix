# Pinned QNapi d4e0378, including libmaia and qt-maybe.
# Nixpkgs comes from ./flake.lock.
#   nix build -f qnapi.nix -o result-qnapi
#
# Darwin: result-qnapi/Applications/QNapi.app and result-qnapi/bin/{qnapi,qnapic}
# Linux:  result-qnapi/bin/{qnapi,qnapic}
{ pkgs ? import
    (fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsLock.rev}.tar.gz";
      sha256 = nixpkgsLock.narHash;
    })
    {
      system = builtins.currentSystem;
      config.allowUnfree = true;
    }
, nixpkgsLock ? (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked
}:

let
  src = pkgs.fetchgit {
    url = "https://github.com/QNapi/qnapi.git";
    rev = "d4e0378a601838a96b7ee25ff48a8eaf18388fcd";
    hash = "sha256-Epl9/Tw+FfnbnZGczAw1Yt8bjEsnZnxVBSh0rcA/wP4=";
    fetchSubmodules = true;
  };
in
pkgs.libsForQt5.callPackage
  (
    { lib
    , stdenv
    , qtbase
    , qmake
    , wrapQtAppsHook
    , libmediainfo
    , p7zip
    , pkg-config
    , zlib
    }:
    stdenv.mkDerivation {
      pname = "qnapi";
      version = "0.2.4-snapshot";

      inherit src;

      nativeBuildInputs = [
        qmake
        wrapQtAppsHook
        pkg-config
      ];

      buildInputs = [
        qtbase
        libmediainfo
        zlib
      ];

      # .pro pins INSTALL_PREFIX to /usr. -after wins over that assignment.
      # link_pkgconfig lets libqnapi see libmediainfo headers on Linux.
      qmakeFlags = [
        "CONFIG+=link_pkgconfig"
        "-after"
        "INSTALL_PREFIX=${placeholder "out"}"
      ];

      # Drop the Intel-era 10.8 deployment pin so the Nix SDK target is used.
      postPatch = ''
        sed -i \
          -e '/QMAKE_MACOSX_DEPLOYMENT_TARGET/d' \
          -e '/QMAKE_CXXFLAGS_X86_64/d' \
          gui/gui.pro cli/cli.pro libqnapi/libqnapi.pro
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        if [ -d macx/QNapi.app ]; then
          mkdir -p $out/Applications
          cp -R macx/QNapi.app $out/Applications/QNapi.app
          # Vendored 7za and libmediainfo are x86_64. Runtime uses Nix p7zip
          # (PATH) and libmediainfo (DYLD_LIBRARY_PATH) via the Qt wrapper.
          rm -f $out/Applications/QNapi.app/Contents/MacOS/libmediainfo*.dylib
          rm -f $out/Applications/QNapi.app/Contents/Resources/7za
          install -m755 macx/qnapic $out/bin/qnapic
          ln -s $out/Applications/QNapi.app/Contents/MacOS/QNapi $out/bin/qnapi
        else
          install -m755 qnapi $out/bin/qnapi
          install -m755 qnapic $out/bin/qnapic
          mkdir -p \
            $out/share/applications \
            $out/share/man/man1 \
            $out/share/man/it/man1 \
            $out/share/man/pl/man1
          cp doc/qnapi.desktop $out/share/applications/
          cp doc/man/qnapi.1.gz $out/share/man/man1/
          cp doc/man/it/qnapi.1.gz $out/share/man/it/man1/
          cp doc/man/pl/qnapi.1.gz $out/share/man/pl/man1/
          for size in 16 32 48 128 512; do
            dest=$out/share/icons/hicolor/''${size}x''${size}/apps
            mkdir -p "$dest"
            cp gui/res/icons/''${size}x''${size}/apps/qnapi.png "$dest/"
          done
        fi
        runHook postInstall
      '';

      qtWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${p7zip}/bin"
      ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "--prefix"
        "DYLD_LIBRARY_PATH"
        ":"
        "${libmediainfo}/lib"
      ];

      meta = {
        description = "Automatic subtitle downloader";
        homepage = "https://qnapi.github.io";
        license = lib.licenses.gpl2Plus;
        platforms = lib.platforms.unix;
        mainProgram = "qnapi";
      };
    }
  )
{ }
