use strict;
use warnings;

# this thing can be done through
# a simple finite state machine
#
#    #states
#    e0
#    e1
#    e2
#    #initial
#    e0
#    #accepting
#    e0
#    #alphabet
#    0
#    1
#    #transitions
#    e0:0>e0
#    e0:1>e1
#    e1:0>e2
#    e1:1>e0
#    e2:0>e1
#    e2:1>e2
#
# we know that AUT = REG
# so, I just generated it there:
# https://ivanzuzak.info/noam/webapps/fsm2regex/
#
# then minified the result by hand
# and got ^(0|1(01*0)*1)+$
#
# which generates obviously 
# things divisible by 3
# 
# but does it in reverse?
# capture all of them
#
# lets do induction by length of the number
#
# if x ends with `0`, then the divident x >> 1
# will also divide by three and by induction 
# the regex matches x >> 1, but given this regex
# we match {x >> 1}0 too, hence proven
#
# if it ends with `1` then reverting back
# the states it goes like this
#
# e0 = e1 `1`
# e1 = e0 `1` @ matches by induction
# e1 = e2 `0`
# e2 = e1 `0`
# e2 = e2 `1`
#
# and so one can say that we 
# start with 1 and return from recursion
# with 1
# 
# inside we have multiple e2 `0` calls
# again we will go back out from e2
# only with e1 `0` call
#
# and at the lowest point we just 
# iterate ones
#
# this whole process is clearly 
# captured by 1(01*0)1 regex
# 
# and thus we match by induction
#

while (<>) {
  print if /^(0|1(01*0)*1)+$/
}
