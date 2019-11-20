#!/bin/sh -l

echo "Hello $1"
echo $(type planemo)
planemo lint --recursive .
