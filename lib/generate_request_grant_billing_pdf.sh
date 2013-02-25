#!/bin/sh

ruby_args="-I../lib -I../app -Ilib"
ruby $ruby_args generate_request_grant_billing_pdf.rb
