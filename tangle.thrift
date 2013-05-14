#!/usr/local/bin/thrift --gen rb --out gen

# Tangle Service
# This file defines the RPC interface. Use `./tangle.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

# server information
struct TangleInfo {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

exception SSHException {
  1: string message
}

service Tangle {
  string      ping()
  TangleInfo  info()
  i64         ssh(1: string user_id,
                  2: string vm_class) throws (1: SSHException e)
}
