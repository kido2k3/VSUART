#!/bin/csh

echo "Cleaning up simulation files..."
rm -f ../log/*
rm -f *.log
rm -f *.wdb
rm -f *.pb
rm -f *.jou
rm -f *.out

rm -rf work
rm -rf xsim.dir
rm -rf xsim.codeCov
rm -rf xsim.covdb
rm -rf .Xil

echo "Cleanup complete."
