#!/usr/local/bin/thrift --gen rb --out gen

# Judge Service
# This file defines the RPC interface. Use `./judge.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

struct JudgeInfo {
  1: double           uptime,
  2: map<string, i32> threads
}

service Judge {
  string ping()
  JudgeInfo info()
}
