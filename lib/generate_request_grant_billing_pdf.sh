#!/bin/sh

ruby_args="-I../lib -I../app -Ilib -I../config"
ruby $ruby_args generate_request_grant_billing_pdf.rb
