{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage {
  pname = "catppuccin-catwalk";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "toolbox";
    rev = "b38153e94622bab574224bb24a6ae953b3a849da";
    hash = "sha256-zZRl6Xem41pBQmEoK24YR4TKiQ84nU5phBih2TF8G8g=";
  };

  buildAndTestSubdir = "catwalk";
  cargoHash = "sha256-KoxivYLzJEjWbxIkizrMpmVwUF7bfVxl13H774lzQRg=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd catwalk \
      --bash <("$out/bin/catwalk" completion bash) \
      --zsh <("$out/bin/catwalk" completion zsh) \
      --fish <("$out/bin/catwalk" completion fish)
  '';

  meta = with lib; {
    homepage = "https://github.com/catppuccin/toolbox/tree/main/catwalk";
    description = "A CLI for Catppuccin that takes in four showcase images and displays them all at once";
    license = licenses.mit;
    maintainers = with maintainers; [ ryanccn ];
    mainProgram = "catwalk";
  };
}
