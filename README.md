# Bechamel 

  Bechamel is a fork of [Bech32-elixir](https://github.com/f2pool/bech32-elixir).
  Not much was changed, apart from updating for newer Elixir versions, better tests and better error handling.

  This is an implementation of BIP-0173, "Bech32 address format for native v0-16 witness outputs".

  See https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki for details.
  
  This library was implemented with Bitcoin and Nervos CKB in mind.

  Forked from Eric des Courtis' now unmaintained [implementation](https://github.com/f2pool/bech32-elixir).

  No dependencies, min elixir version: `1.15`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bechamel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bechamel, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bechamel](https://hexdocs.pm/bechamel).

