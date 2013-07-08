#!/bin/sh

ruby_args="-I../lib -I../app -Ilib"
bundle exec ruby $ruby_args import_notifications.rb
