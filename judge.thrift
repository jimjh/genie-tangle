#!/usr/local/bin/thrift --gen rb --out gen

# Judge Service
# (Wow. I never knew magic cookies work that way.)
# Jim Lim <jiunnhal@cmu.edu>

service Judge {

  # ping pong!
  string ping()

}
