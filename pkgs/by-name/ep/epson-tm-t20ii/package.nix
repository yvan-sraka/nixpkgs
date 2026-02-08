{
  lib,
  stdenv,
  fetchFromGitHub,
  cups,
}:

stdenv.mkDerivation {
  pname = "epson-tm-t20ii";
  version = "0-unstable-2017-10-07";

  src = fetchFromGitHub {
    owner = "nemik";
    repo = "epson-tm-t20-cups";
    rev = "7919a1dcbfa0547105409202042791c711fe2cb3";
    hash = "sha256-cirrbY771P4y5Fd943VvLuri0rc7+OK2TLlMUt9U+Fs=";
  };

  buildInputs = [ cups ];

  patches = [
    # Fix inline function linkage issues - all inline functions need to be static inline
    ./patches/fix-inline-functions.patch
  ];

  postPatch = ''
    # Remove pre-built binary to ensure we build from source
    rm -f rastertozj

    # Fix Makefile to use CC variable properly
    substituteInPlace Makefile \
      --replace-fail 'gcc $(LDFLAGS)' '$(CC) $(LDFLAGS)' \
      --replace-fail 'gcc $(CFLAGS)' '$(CC) $(CFLAGS)'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 rastertozj $out/lib/cups/filter/rastertozj
    install -Dm644 tm20.ppd $out/share/cups/model/epson/tm-t20ii.ppd

    # Patch PPD to use absolute path to the filter
    substituteInPlace $out/share/cups/model/epson/tm-t20ii.ppd \
      --replace-fail 'rastertozj' "$out/lib/cups/filter/rastertozj"

    runHook postInstall
  '';

  meta = {
    description = "CUPS driver for Epson TM-T20 and TM-T20II thermal receipt printers";
    homepage = "https://github.com/nemik/epson-tm-t20-cups";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ];
  };
}
