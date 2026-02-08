{
  lib,
  stdenv,
  fetchurl,
  cups,
  dpkg,
  makeWrapper,
  ghostscript,
  file,
  gnused,
  gnugrep,
  coreutils,
  perl,
  which,
}:

stdenv.mkDerivation rec {
  pname = "brother-hll2400dwe";
  version = "4.1.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf105949/hll2400dwepdrv-${version}.i386.deb";
    hash = "sha256-HjiLCNZwM1bERpVBfnIXfHdYCWN8HOurKHWdh22l63Y=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  buildInputs = [
    cups
    ghostscript
    perl
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    dpkg-deb -x $src $out

    # Patch the Perl filter script
    substituteInPlace $out/opt/brother/Printers/HLL2400DWE/lpd/lpdfilter \
      --replace-fail "/usr/bin/perl" "${perl}/bin/perl"

    substituteInPlace $out/opt/brother/Printers/HLL2400DWE/cupswrapper/lpdwrapper \
      --replace-fail "/usr/bin/perl" "${perl}/bin/perl"

    # Patch the x86_64 binaries (use i686 for 32-bit systems)
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/opt/brother/Printers/HLL2400DWE/lpd/x86_64/brprintconflsr3
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/opt/brother/Printers/HLL2400DWE/lpd/x86_64/rawtobr3

    # Create architecture-specific symlinks
    ln -sf $out/opt/brother/Printers/HLL2400DWE/lpd/x86_64/brprintconflsr3 \
      $out/opt/brother/Printers/HLL2400DWE/lpd/brprintconflsr3
    ln -sf $out/opt/brother/Printers/HLL2400DWE/lpd/x86_64/rawtobr3 \
      $out/opt/brother/Printers/HLL2400DWE/lpd/rawtobr3

    # Wrap scripts with required tools
    for f in \
      $out/opt/brother/Printers/HLL2400DWE/cupswrapper/lpdwrapper \
      $out/opt/brother/Printers/HLL2400DWE/cupswrapper/paperconfigml2 \
    ; do
      wrapProgram $f \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            ghostscript
            gnugrep
            gnused
          ]
        }
    done

    wrapProgram $out/opt/brother/Printers/HLL2400DWE/lpd/lpdfilter \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          file
          ghostscript
          gnugrep
          gnused
          which
        ]
      }

    # Create CUPS filter symlink
    mkdir -p $out/lib/cups/filter
    ln -s $out/opt/brother/Printers/HLL2400DWE/cupswrapper/lpdwrapper \
      $out/lib/cups/filter/brother_lpdwrapper_HLL2400DWE

    # Install PPD file
    mkdir -p $out/share/cups/model
    ln -s $out/opt/brother/Printers/HLL2400DWE/cupswrapper/brother-HLL2400DWE-cups-en.ppd \
      $out/share/cups/model/

    runHook postInstall
  '';

  meta = {
    description = "Brother HL-L2400DWE printer driver";
    homepage = "https://www.brother.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
