{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, fetchurl ? pkgs.fetchurl
, makeDesktopItem ? pkgs.makeDesktopItem
, copyDesktopItems ? pkgs.copyDesktopItems
}:

let
pname = "dn-famitracker";
pversion = "0.5.0.2";

in
stdenv.mkDerivation rec {
  name = pname;
  version = pversion;

  buildInputs = [ pkgs.imagemagick pkgs.copyDesktopItems pkgs.p7zip ];

  src = fetchurl {
    url = "https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/download/Dn0.5.0.2/Dn-FamiTracker_v0502_x64_Release.7z";
    sha256 = "sha256-Rr4WNKGuVwEj9Wf/yDBkCubhvRA4m5WTsMZGZnaafU0=";
  };

  srcIcon = fetchurl {
    url = "https://raw.githubusercontent.com/Dn-Programming-Core-Management/Dn-FamiTracker/main/res/Application.ico";
    sha256 = "sha256-CTwhRJkswtBd7VZTRC+cyijdX+X89Ew6lu4TmjfGuqc=";
  };

  desktopItems = [
    (makeDesktopItem rec {
      name = "Dn-FamiTracker";
      desktopName = "Dn-FamiTracker";
      exec = "dn-famitracker";
      icon = "dn-famitracker";
      type = "Application";
      comment = "Fork of 0cc-FamiTracker (a NES tracker) that incorporates numerous fixes and features.";
      categories = [ "Audio" "Sequencer" "Midi" "AudioVideoEditing" "Music" "AudioVideo" ];
      mimeTypes = [ "audio/x-famitracker" "audio/x-dnfamitracker" ];
      # TODO: file associations (somehow)
    })
  ];

  installPhase = ''
    mkdir -p $out $out/bin $out/share/dn-famitracker $out/share/pixmaps $out/share/mime/packages/

    7z x "${src}" -o$out/share/dn-famitracker/

    cat <<EOT >> $out/bin/dn-famitracker
    #!/bin/bash
    export WINEPREFIX=~/.dn-famitracker
    [[ "\$1" == "" ]] && wine $out/share/dn-famitracker/Dn-FamiTracker.exe
    [[ "\$1" != "" ]] && wine $out/share/dn-famitracker/Dn-FamiTracker.exe "\$(winepath -w "\$1")"
    EOT
    chmod +x $out/bin/dn-famitracker

    convert ${srcIcon} $out/share/pixmaps/dn-famitracker.png
    mv $out/share/pixmaps/dn-famitracker-8.png $out/share/pixmaps/temp.png
    rm $out/share/pixmaps/dn-famitracker*.png
    mv $out/share/pixmaps/temp.png $out/share/pixmaps/dn-famitracker.png

    cat <<EOT >> $out/share/mime/packages/dn-famitracker.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="audio/x-famitracker">
        <glob pattern="*.ftm"/>
        <glob pattern="*.FTM"/>
        <comment>FamiTracker Module</comment>
        <icon name="dn-famitracker"/>
      </mime-type>
      <mime-type type="audio/x-dnfamitracker">
        <glob pattern="*.dnm"/>
        <glob pattern="*.DNM"/>
        <comment>Dn-FamiTracker Module</comment>
        <icon name="dn-famitracker"/>
      </mime-type>
    </mime-info>
    EOT

    copyDesktopItems
  '';

  meta = with lib; {
    description = "Fork of 0cc-FamiTracker (a NES tracker) that incorporates numerous fixes and features.";
    homepage = "https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker";
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" ];
  };

}
