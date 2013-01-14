#!/bin/sh

ruby_args="-I../lib -I../app -Ilib"
ruby $ruby_args dump_pricing.rb
