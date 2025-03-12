# config

Repository for managing and configuring my system. Dotfiles, configs, user services and helful scripts.

## Usage

Assuming `~/.local/bin` is added to `$PATH`, install config script via

```sh
./config.sh init
```

You only need to call `init` once, any changes to this repo can be seen by the system by calling:

```sh
config sync
```

## Future plans/features

- To edit git config:

```sh
./config.sh git edit
./config sync
```

- Switch to python or ruby for config script?
- Load/Store `config.json` more dynamically

### Notes

- `dotfiles/.local/bin` contains out of date, unused user scripts
