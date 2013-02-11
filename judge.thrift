#!/usr/local/bin/thrift --gen rb --out gen

# Judge Service
# This file defines the RPC interface. Use `./judge.thrift` to compile it and
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

struct JudgeJob {
  1: optional bool        assigned,        # true if job has been assigned
  2: optional i32         retries,         # number of retries
  3: required string      name,            # name for the debug logs
  4: optional map<string, string> params,  # variable arguments for driver
  5: optional list<string>        trace,   # debug trace
  6: optional i32         errors,          # number of errors
  7: optional i32         timeout,         # timeout in seconds, for job execution
  8: required list<Input> inputs,          # list of input files
  9: required string      output,          # path to output file
 10: optional i32         fsize            # maximum output file size, in bytes
}

struct JudgeInfo {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

service Judge {
  string ping()
  JudgeInfo info()
  Status add_job(1: JudgeJob job, 2: string reply_to, 3: string identifier)
}
