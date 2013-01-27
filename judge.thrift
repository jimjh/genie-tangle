#!/usr/local/bin/thrift --gen rb --out gen

# Judge Service
# This file defines the RPC interface. Use `./judge.thrift` to compile it and
# generate the ruby files.
# (Wow. I never knew magic cookies work that way.)
# Jim Lim <jiunnhal@cmu.edu>

service Judge {

  # ping pong!
  string ping()

}
