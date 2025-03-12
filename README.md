# config

Repository for managing and configuring my system

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

- bring suckless software up to date
- switch to python or ruby for config script
- load/store `config.json` more dynamically
- update scripts in `dotfiles/.local/bin`
- ability to edit config of other programs, like git:

```sh
./config.sh git edit
```
