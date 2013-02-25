#!/usr/local/bin/thrift --gen rb --out gen

# Tangle Service
# This file defines the RPC interface. Use `./tangle.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

struct Input {
  1: required string local,      # path to local file
  2: optional string dest        # path to destination file
}

enum StatusCode {
  SUCCESS,
  FAILURE
}

struct Status {
  1: StatusCode   code,
  2: list<string> trace
}

struct TangleInfo {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

service Tangle {
  string ping()
  TangleInfo info()
}
