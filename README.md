# Judge

Judge is a job management service that manages requests for jobs to be run on
virtual machines. In particular, it provides an autograding service for Genie.
Judge consists of the following components:

1. Judge Server: a Thrift RPC server. Validates job requests and places them on
a queue.

## Usage
To get a list of all commands and their options, use

```sh
$ judge help
```

To start the server on OS-selected port, use

```sh
$ judge server
```

To start the client, use

```sh
$ judge client --port=PORT [COMMAND]
```

If `COMMAND` is not provided, a pry console will be launched. For example

```
$ bin/judge client --port=12345
[1] pry(#<Judge::Client>)> info
=> <JudgeInfo uptime:744.226172, threads:{"total": 22, "running": 1}>
```
