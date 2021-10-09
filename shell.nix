let

  niv-sources = import ./nix/sources.nix;
  niv-pkgs = import niv-sources.nixpkgs { };

  holonixPath = builtins.fetchTarball {
    url = "https://github.com/holochain/holonix/archive/48a75e79b1713334ab0086767a214e5b1619d38d.tar.gz";
    sha256 = "sha256:0r8ph5l00g70lr7lfcipnsv5vcagq5b51in232gdbglw9ngk8048";
  };
  holonix = import (holonixPath) {
    include = {
        holochainBinaries = true;
    };

    holochainVersionId = "custom";

    holochainVersion = {
      rev = "holochain-0.0.109";
      sha256 = "1rwss1y8cd52ccd0875pfpbw6v518vcry3hjc1lja69x2g2x12qb";
      cargoSha256 = "08a72d7nqpakml657z9vla739cbg8y046av4pwisdgj1ykyzyi60";
      bins = {
        holochain = "holochain";
        hc = "hc";
        kitsune-p2p-proxy = "kitsune_p2p/proxy";
      };

      lairKeystoreHashes = {
        sha256 = "12n1h94b1r410lbdg4waj5jsx3rafscnw5qnhz3ky98lkdc1mnl3";
        cargoSha256 = "0axr1b2hc0hhik0vrs6sm412cfndk358grfnax9wv4vdpm8bq33m";
      };
    };
  };
  nixpkgs = holonix.pkgs;

in

nixpkgs.mkShell {
  inputsFrom = [ holonix.main ];
  buildInputs = (with nixpkgs; [
    binaryen
  ]) ++ (with niv-pkgs; [
    miniserve
    nodePackages.rollup
    wasm-pack
  ]);
}
