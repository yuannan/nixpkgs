{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  jre_headless,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "purpur";
  version = "26.2r2620";

  src = fetchurl {
    url = "https://api.purpurmc.org/v2/purpur/${
      builtins.replaceStrings [ "r" ] [ "/" ] finalAttrs.version
    }/download";

    sha256 = "sha256-IQA6i/GAhVv4s83XIS1rb/dvBt5dy6hHQMPtQzumw00=";
  };

  nativeBuildInputs = [ makeWrapper ];

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    makeWrapper ${jre_headless}/bin/java $out/bin/minecraft-server \
      --add-flags "-jar $out/lib/minecraft/server.jar nogui"
  '';

  dontUnpack = true;

  passthru = {
    tests = { inherit (nixosTests) minecraft-server; };
  };

  meta = {
    description = "Drop-in replacement for Minecraft Paper servers";
    longDescription = ''
      Purpur is a drop-in replacement for Minecraft Paper servers designed for configurability, new fun and exciting
      gameplay features, and performance built on top of Airplane.
    '';
    homepage = "https://purpurmc.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      yuannan
    ];
    mainProgram = "minecraft-server";
  };
})
