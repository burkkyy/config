# config
Repository for managing and configuring my system. Dotfiles, configs, user services and helful scripts.

To install the config command:
```bash
./config
```

## Example Usage
To edit git config: 
```bash
./config.sh git edit
./config sync
```

If instaled:
```bash
config sync
```

## Adding your own options to config command
Create a bash script file in `bin/`.
**Ex.** `bin/hello.sh`
```bash
echo "hello $1"
```

Assuming config is installed, this script can be called via:
```
config hello joe
```
**NOTE:** Arguments passed to hello are original order. ie. $0 is hello and $1 is joe

## Notes
- `dotfiles/.local/bin` contains out of date, unused user scripts

