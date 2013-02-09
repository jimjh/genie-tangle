#!/usr/local/bin/thrift --gen rb --out gen

# Judge Service
# This file defines the RPC interface. Use `./judge.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

struct Input {
  1: string local,      # path to local file
  2: string dest        # path to destination file
}

struct JudgeJob {
  1: i32         id,              # client-specific ID
  2: i32         assigned,        # ID of assigned VM
  3: i32         retries,         # number of retries
  6: string      name,            # name for the debug logs
  7: map<string, string> args,    # variable arguments for driver
  8: list<string>        trace,   # debug trace
  9: i32         timeout,         # timeout in seconds, for job execution
 10: list<Input> inputs,          # list of input files
 11: string      output,          # path to output file
 10: i32         fsize            # maximum output file size, in bytes
}

struct JudgeInfo {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

service Judge {
  string ping()
  JudgeInfo info()
}
