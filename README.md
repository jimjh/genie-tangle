# Tangle

Tangle manages a pool of VMs and SSH connections to them.

Clients are typically web servers. A client can request for an SSH channel
by invoking

    ssh(user_id, vm_class, output)

which returns the path to a new input pipe to a SSH channel. If a connection to
a VM of the requested `vm_class` for the `user_id` already exists, it's reused;
otherwise, Tangle creates a new SSH connection. Standard out and standard error
from these sessions are published to a push-only Faye server on the specified
`output` channel.

Tangle also acts as a load balancer, and expands/shrinks the pool of VMs as
demand rises/falls. This also means that clients need to handle errors from
closed pipes, which indicate that the SSH connection has been evicted (closed).

If a web client wishes to execute a slow command via the SSH channel, it should
do so asynchronously (_i.e._ not block.)

## Usage
To get a list of all commands and their options, use

```sh
$ tangle help
```

To start the server on OS-selected port, use

```sh
$ tangle server --port=0
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

## Security
(see https://blog.gregbrockman.com/2012/08/system-design-stripe-capture-the-flag/)
The following steps were taken to secure the VMs

### PAM
Added

    session    optional     pam_umask.so umask=0027

to `/etc/pam.d/sshd` and `/etc/pam.d/login`

Added

    session required pam_limits.so

to `/etc/pam.d/common-session`

### File Permissions
For `ubuntu` home directory: `chmod -R o-rwx .`

For `/var/log`: `chmod -R o-rx /var/log` then `chmod o+rx /var/log`

For `/etc/passwd`, `/etc/group`: `chmod 600`

### SSH Config
In `/etc/ssh/sshd_config`

    Match Group tangler
      AllowTcpForwarding no

### ulimit

    @tangler        hard    core            0
    @tangler        hard    data            4096
    @tangler        hard    nofile          50
    @tangler        hard    stack           4096
    @tangler        hard    cpu             240
    @tangler        hard    nproc           20
    @tangler        hard    maxlogins       4
    @tangler        hard    maxsyslogins    4
    @tangler        hard    msgqueue        4096
    @tangler        hard    nice            0

updated skel bashrc to not show user, host
