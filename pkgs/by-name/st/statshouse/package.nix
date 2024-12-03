{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  python3Packages,
  withAggregator ? true,
  withAgent ? true,
  withApiService ? true,
  withMetadataService ? true,
}:
let
  version = "2024.11.1"; 

  src = fetchFromGitHub {
    owner = "vkcom";
    repo = "statshouse";
    rev = "v${version}";
    hash = "sha256-/3O045/cTbdb/+/BQJjmgs57a7fgBUL2LmUOqdfaQdM=";
  };

  python = python3Packages.python.withPackages (ps: with ps; [
    distutils
  ]);

  frontend = buildNpmPackage rec {
    pname = "statshouse-ui";
    inherit version src;

    sourceRoot = "${src.name}/statshouse-ui";
    npmDepsHash = "sha256-V13l/4rcdfZLvhSzyxmSusTxoO+yleintyg+nqKAvoo=";

    nativeBuildInputs = [ python ];

    installPhase = ''
      mkdir $out
      mv build $out
    '';
  };

in 
buildGoModule {
  pname = "statshouse";
  inherit version src;

  vendorHash = "sha256-4clK971QuzW9Ni+Wdd5/TIsCL8QQz+piuZHsDbsqzYI";

  ldflags = [
    "-X github.com/vkcom/statshouse/internal/vkgo/build.version=${version}"
    "-X github.com/vkcom/statshouse/internal/vkgo/build.time=1970-01-01T00:00:00Z"
    "-X github.com/vkcom/statshouse/internal/vkgo/build.commit=${src.rev}"
  ];

  proxyVendor = true;

  subPackages = lib.optionals (withAgent || withAggregator) [ "cmd/statshouse" ]
    ++ lib.optionals withApiService [ "cmd/statshouse-api" ]
    ++ lib.optionals withMetadataService [ "cmd/statshouse-metadata" ];

  preBuild = lib.optionals withApiService ''
    mkdir -p $out/ui
    cp -r ${frontend}/build/* $out/ui
  '';

  meta = with lib; {
    homepage = "https://vkcom.github.io/statshouse/";
    description = "StatsHouse is a highly available, scalable, multitenant monitoring system.";
    license = licenses.mpl20;
    maintainers = with maintainers; [ arezvov ];
    changelog = "https://github.com/VKCOM/statshouse/releases/tag/v${version}";
    mainProgram = "statshouse";
  };
}
