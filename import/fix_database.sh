#!/bin/bash

set -e

basedir=$(dirname $(readlink -f $0))

run()
{
  cd $basedir/../../migration_scripts
  RUBYLIB=$(pwd)/lib:$RUBYLIB ruby -rrun -e "$*"
  cd -
}

source ~/.rvm/scripts/rvm

# run 'AddPricingSetup.add_pricing_setup' # don't need to create empty pricing setups
run 'AddPricingSetup.remove_rates_hash'
run 'SetHistoric.set_historic_true'
# run 'FixBadDates.fix_bad_dates'   # has been run already
# run 'FixBadDates.find_exceptions' # has been run already
run 'ChangePricingMap.change_pricing_map'
run 'ChangePricingMap.new_structure'
run 'ChangePricingMap.add_display_dates'
# run 'FixBadTypes.update_projects'  # has been run already
# run 'Credentials.update_users'     # has been run already
# run 'Irb.update_projects'          # has been run already
# run 'Quantities.update_srs'        # has been run already
# run 'Legacy.create_projects'       # has been run already
# run 'Legacy.create_users'          # has been run already
# run 'Legacy.create_roles'          # has been run already

