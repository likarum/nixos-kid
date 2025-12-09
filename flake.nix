{
  description = "NixOS Kid-Friendly Configuration - Environnement enfant avec applications éducatives en français";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      kid-friendly = import ./modules/kid-friendly.nix;
      education = import ./modules/education.nix;
      games = import ./modules/games.nix;
      parental = import ./modules/parental.nix;
    };

    nixosModules.default = self.nixosModules.kid-friendly;
  };
}
