{ stdenv, lib, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation ( finalAttrs: {
  name = "blst-0.3.10";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "03b5124029979755c752eec45f3c29674b558446";
    hash = "sha256:01m28xxmm1x7riwyax7v9rycwl5isi06h2b2hl4gxnnylkayisn5";
  };

  buildPhase = ''
    runHook preBuild

    ./build.sh

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp ./libblst.a $out/lib/

    runHook postInstall
  '';

  enableParallelBuilding = true;

  doCheck = true;

  meta = with lib; {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    license = licenses.isc;
    maintainers = with maintainers; [ iquerejeta ];
    platforms = platforms.all;
  };
})
