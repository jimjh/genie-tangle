# Tangle

Tangle manages a pool of VMs and SSH connections to them.

## Usage
To get a list of all commands and their options, use

```sh
$ tangle help
```

To start the server on OS-selected port, use

```sh
$ tangle server
```

To start the client, use

```sh
$ tangle client --port=PORT [COMMAND]
```

If `COMMAND` is not provided, a pry console will be launched. For example

```
$ bin/tangle client --port=12345
[1] pry(#<Tangle::Client>)> info
=> <TangleInfo uptime:744.226172, threads:{"total": 22, "running": 1}>
```
