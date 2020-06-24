# nixos-config

My NixOS configuration that hopefully works for other platforms as well. The notion of using [`home-manager`](https://github.com/rycee/home-manager) not because of planning on using multi-user machines, but to make the config more portable, in case I ever need to use Ubuntu or Darwin. The idea is that I would just install the [Nix package manager](https://nixos.org/), copy `home.nix` (with the related dotfiles), and that's it.

## TODOs

1. Create `home.nix` and source it in `configration.nix`. See ["Managing configuration.nix and home.nix" reddit post](https://www.reddit.com/r/NixOS/comments/ec3je7/managing_configurationnix_and_homenix/).

2. Test whether using [`home-manager`](https://github.com/rycee/home-manager) is portable (i.e., using `home.nix` on other Linux distros works).
