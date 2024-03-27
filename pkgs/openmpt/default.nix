{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, fetchzip ? pkgs.fetchzip
, makeDesktopItem ? pkgs.makeDesktopItem
, copyDesktopItems ? pkgs.copyDesktopItems
}:

let
pname = "openmpt";
pversion = "1.31.06.00";

in
stdenv.mkDerivation {
  name = pname;
  version = pversion;

  buildInputs = [ pkgs.imagemagick pkgs.copyDesktopItems ];

  # mversion = "1.31";

  src = fetchzip {
    url = "https://download.openmpt.org/archive/openmpt/1.31/OpenMPT-${pversion}-portable-amd64.zip";
    sha256 = "sha256-TZBKXKE2YsS7f5KbUeyDtQ58oKKVki+NiOEFWrKvrK4=";
    stripRoot = false;
  };

  sourceRoot = "source";

  desktopItems = [
    (makeDesktopItem rec {
      name = "OpenMPT";
      desktopName = "OpenMPT";
      exec = "openmpt";
      icon = "openmpt";
      type = "Application";
      comment = "Open-source audio module tracker";
      categories = [ "Audio" "Sequencer" "Midi" "AudioVideoEditing" "Music" "AudioVideo" ];
      mimeTypes = [ "audio/x-mod" "audio/x-s3m" "audio/x-xm" "audio/x-it" "audio/x-mptm" ];
    })
  ];


  installPhase = ''
    mkdir -p $out/bin $out/share/openmpt $out/share/pixmaps $out/share/mime/application/ $out/share/applications

    cp -vr * $out/share/openmpt

    convert OpenMPT\ File\ Icon.ico $out/share/pixmaps/openmpt.png
    mv $out/share/pixmaps/openmpt-2.png $out/share/pixmaps/temp.png
    rm $out/share/pixmaps/openmpt*.png
    mv $out/share/pixmaps/temp.png $out/share/pixmaps/openmpt.png

    cat <<EOT >> $out/bin/openmpt
    #!/bin/bash
    export WINEPREFIX=~/.openmpt
    [[ "\$1" == "" ]] && wine $out/share/openmpt/OpenMPT.exe
    [[ "\$1" != "" ]] && wine $out/share/openmpt/OpenMPT.exe "\$(winepath -w "\$1")"
    EOT
    chmod +x $out/bin/openmpt

    cat <<EOT >> $out/share/mime/application/x-mptm.xml
    <mime-type type="audio/x-mptm">
      <glob pattern="*.mptm"/>
      <comment>OpenMPT Module</comment>
    </mime-type>
    EOT

    copyDesktopItems
  '';

  meta = with lib; {
    description = "Open-source audio module tracker";
    homepage = "https://openmpt.org/";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ]; # TODO: aarch64
  };

}
