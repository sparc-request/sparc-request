#!/bin/bash

# This is a master script for the import process.  It will:
#   * Create the sql database
#   * Fetch all the entities from the couch databaes
#   * Import the fetched entnties into the sql database
#   * Import the relationships into the sql database
#   * Validate that everything was imported correctly

set -e
# set -x

pprof()
{
  perftools_gem=$(gem which perftools | sort | tail -1)
  CPUPROFILE=import.rb.prof RUBYOPT="-rubygems -r$perftools_gem" ruby -I../lib $*
}

migrate()
{
  cd ../../sparc-rails
  rake db:drop
  rake db:create
  rake db:migrate
  cd -
}

save_state()
{
  name="$1"
  if [ "$save_state" ]; then
    echo "Saving state to $name.sql"
    mysqldump sparc_development --user=sparc --password=sparc > $name.sql
  fi
}

restore_state()
{
  name="$1"
  echo "Restoring state from $name.sql"
  mysql sparc_development --user=sparc --password=sparc < $name.sql
}

import_args="-N"
import_relationships_args=""
validate_args=""
save_state=1
ruby_args="-I../lib -I../validate"
skip_to="start"

while getopts "O:S:" opt; do
  case $opt in
    O)
      echo "Importing only $OPTARG"
      import_args="-O $OPTARG"
      import_relationships_args="-O $OPTARG"
      validate_args="-O $OPTARG"
      save_state=0
      ;;

    S)
      echo "Skipping to step $OPTARG"
      skip_to="$OPTARG"
      ;;

    \?)
      echo "Invalid option: -$OPTARG"
      ;;

  esac
done

source ~/.rvm/scripts/rvm

case "$skip_to" in
  start)
    ;;

  migrate)
    ;;

  get)
    restore_state 'migrated'
    ;;

  identities)
    restore_state 'migrated'
    ;;

  entities)
    restore_state 'imported_identities'
    ;;

  relationships)
    restore_state 'imported_entities'
    ;;

  validate)
    restore_state 'imported_relationships'
    ;;

  *)
    echo "Invalid argument for 'skip to': $skip_to"
    exit 1
    ;;
esac

case "$skip_to" in
  start)
    ;&

  migrate)
    migrate
    save_state 'migrated'
    ;&

  get)
    echo "Getting entities from couchdb"
    curl -X GET 'http://localhost:4567/obisentity/entities/' > entities.json 
    ;&

  identities)
    echo "Importing identities into sql"
    ruby $ruby_args import.rb $import_args --import-identities
    save_state 'imported_identities'
    ;&

  entities)
    echo "Importing other entities into sql"
    # pprof import.rb -N -n 2000 -X
    ruby $ruby_args import.rb $import_args --import-others
    save_state 'imported_entities'
    ;&

  relationships)
    echo "Importing relationships into sql"
    ruby $ruby_args import_relationships.rb $import_relationships_args
    save_state 'imported_relationships'
    ;&

  validate)
    echo "Validating import"
    ruby $ruby_args validate.rb $validate_args
    ;&
esac

