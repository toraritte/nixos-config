# nixos-config

My  NixOS  configuration  that hopefully  works  for
other platforms as well. The notion of using
[`home-manager`](https://github.com/rycee/home-manager)
not   because  of   planning  on   using  multi-user
machines, but  to make the config  more portable, in
case I ever  need to use Ubuntu or  Darwin. The idea
is that I would just install the
[Nix package manager](https://nixos.org/),
copy `home.nix` (with the dotfiles), and that's it.

## TODOs

1.  Create     `home.nix`    and     source    it     in
`configration.nix` from `home-manager.users.<user>`.
See ["Managing configuration.nix and home.nix" reddit post](https://www.reddit.com/r/NixOS/comments/ec3je7/managing_configurationnix_and_homenix/).

2.  Test whether using
[`home-manager`](https://github.com/rycee/home-manager)
is portable  (i.e., using `home.nix` on  other Linux
distros works).

3.  Create   dotfiles   for  each   application   (e.g.,
`.gitconfig`,  `.vimrc`, etc.),  and source  it from
their respective places in `home.nix`.

4. Add  notes on how  to transfer this  config (and,
eventually,  how to  build  a  custom install  iso),
noting the  pitfalls, such  as make  sure `luksroot`
points to the right device  or that the initial user
has a password.

4.a. Write  posts on  how to get out of the pit
(right now only the two mentioned at the end of item
4. comes to mind). (See `balsors` for the former.)

4.b. `configuration.nix`  is kind  of a  template at
the  moment,  but  it  should be  more  like  a  Nix
function where the pieces (e.g., hostname, luksroot)
can be plugged in and deployed to other machines.
