### Inspiration:
#   * https://github.com/toraritte/shell.nixes/blob/main/elixir-phoenix-postgres/shell.nix

# This defines a function taking `pkgs` as parameter, and uses
# `nixpkgs` by default if no argument is passed to it.
{ pkgs ? import <nixpkgs> {} }:

# This avoids typing `pkgs.` before each package name.
with pkgs;

let
  # https://www.mathiaspolligkeit.com/dev/elixir-dev-environment-with-nix/#overrides
  elixir = beam.packages.erlangR25.elixir_1_13;

  basePackages = [
    elixir
    git
  ];

  inputs = basePackages
    ++ lib.optionals stdenv.isLinux [
      # https://hexdocs.pm/phoenix/installation.html#inotify-tools-for-linux-users
      inotify-tools
    ]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
    ]);

  mixHooks = ''
    # [1] Contain Mix data into the local directory
    #     https://www.mankier.com/1/mix#Environment
    export MIX_HOME="$PWD/.mix"
    export MIX_ARCHIVES="$MIX_HOME/archives"

    # Create the data directory if it does not already exist
    if ! [ -d $MIX_HOME ]; then
      mkdir $MIX_HOME

      # [3] Install Hex, Elixir's package manager
      #     https://hexdocs.pm/mix/main/Mix.Tasks.Local.Hex.html
      mix local.hex --if-missing --force
    fi
  '';

  phxHooks = ''
    if ! mix phx.new --version; then
      export PHX_VERSION="1.6.11"

      # [4] Install the Phoenix generator
      #     https://hexdocs.pm/phoenix/installation.html#phoenix
      #     https://hexdocs.pm/mix/main/Mix.Tasks.Archive.Install.html#module-command-line-options

      mix archive.install hex phx_new $PHX_VERSION --force
    fi
  '';

in

# Defines a shell.
mkShell {
  # Sets the build inputs, i.e. what will be available in our
  # local environment.
  buildInputs = inputs;

  shellHook = mixHooks + phxHooks;
}
