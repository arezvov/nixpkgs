{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "flog";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "mingrammer";
    repo = "flog";
    rev = "v${version}";
    hash = "sha256-y0Ut6+fKeA1wfeN2Pu0ESkOCkiWey5ZEYQT9RYepVcI=";
  };

  vendorHash = "sha256-5W7KXLUhBMcS+ErLp0IrF5sl8++EIyxNFzZPIuP2lGs=";
  proxyVendor = true;

  meta = with lib; {
    homepage = "https://github.com/mingrammer/flog";
    description = "A fake log generator for common log formats";
    license = licenses.mit;
    maintainers = with maintainers; [ arezvov ];
  };
}
