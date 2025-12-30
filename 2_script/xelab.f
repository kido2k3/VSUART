--log ./log/xelab.log
-debug typical 
-timescale 1ns/1ps
// code coverage 
-cc_dir ./coverage
-cc_libs 
-cc_type sbct
// functional coverage
-cov_db_dir ./coverage 