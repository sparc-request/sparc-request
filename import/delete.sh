#!/bin/bash

# This script will remove invalid documents from the database.  These are
# entities and relationships which have been found during the validation
# process to be invalid and will cause either the import or the
# validation to fail.

delete_entity()
{
  type=$1
  obisid=$2
  relid=$3

  echo -n "Delete $type $obisid: "
  curl -X DELETE http://localhost:4567/obisentity/$type/$obisid
  echo
}

delete_relationship()
{
  type=$1
  obisid=$2
  relid=$3

  echo -n "Delete $type $obisid rel $relid: "
  curl -X DELETE http://localhost:4567/obisentity/$type/$obisid/relationships/$relid
  echo
}

delete_all()
{
  while read LINE; do
    eval $LINE
  done
}

# These identities refer to deleted sub service requests
delete_relationship identities 5f0b6e30e3aa70ec08eb8f9f31a2634d 4fd66e8a71893de94fe90b20ad06941c
delete_relationship identities 5f0b6e30e3aa70ec08eb8f9f31a2634d 80c8d616340e7759ad5f1177eeb0c3eb
delete_relationship identities 5f0b6e30e3aa70ec08eb8f9f31a2634d f819a95ba8e706454c4caa6c02d20471
delete_relationship identities 87d1220c5abf9f9608121672be79b613 6613aff69754eec596fbb67ff903c79a
delete_relationship identities 90c9b4cfa4e3fdcb2522864e1d73e4d7 47baa997c443e40ae6519aae09aa9b06
delete_relationship identities 90c9b4cfa4e3fdcb2522864e1d73e4d7 f819a95ba8e706454c4caa6c02262308
delete_relationship identities b22c7a786874f2f334cd856062591a0a 47baa997c443e40ae6519aae095c8a70
delete_relationship identities b22c7a786874f2f334cd856062591a0a 6613aff69754eec596fbb67ff904c11e
delete_relationship identities dc7e992930e5941e8e17c6fc91061af0 572cd448493b45a4ea1fa6a476947e59
delete_relationship identities dc7e992930e5941e8e17c6fc915f8c48 f819a95ba8e706454c4caa6c027d83f7

# I believe the same is true of these identies, but they were deleted before I
# wrote the script to find them
delete_relationship identities 1f5a4fd909e43d857d79220f75180c1a 6613aff69754eec596fbb67ff9e7be56               
delete_relationship identities 3628f23ac15ea7d43ac6fab6ad1464e9 80c8d616340e7759ad5f1177ee49db04
delete_relationship identities 3628f23ac15ea7d43ac6fab6ad1464e9 80c8d616340e7759ad5f1177ee49ff29
delete_relationship identities 3628f23ac15ea7d43ac6fab6ad1464e9 80c8d616340e7759ad5f1177ee4a2fe3

# service request ea1b644e2a682bf72f89a5448304443f has a line item with
# no associated organization (solution: delete this service request and
# its associated line item 87d1220c5abf9f9608121672be052608).
delete_entity line_items 87d1220c5abf9f9608121672be052608
delete_entity service_requests ea1b644e2a682bf72f89a5448304443f

# hvc3 has many fields null
delete_entity identities 5f0b6e30e3aa70ec08eb8f9f31a15e6e

# STAR has been deleted in production (and it has no parents in our test
# database)
delete_entity programs 87d1220c5abf9f9608121672be03d747

# Has sub service requests that refer to a deleted organization
# TODO: Haven't gotten a clear answer whether this service request
# should be deleted
delete_entity service_requests 179eae3982ab1e4047051381fb71199d

# Has line items with no sub service request id and is in draft status
delete_entity service_requests 4cd4342ccf3f916a2d9bad74d581e746

# BigIP monitor has no email
delete_entity identities 179eae3982ab1e4047051381fb0c63d2

# Duplicate identities for Lane
delete_entity identities 87d1220c5abf9f9608121672be282036
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b13b9e
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b36433
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b39a1b
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b3bf21
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b40040
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b45197
delete_relationship identities 87d1220c5abf9f9608121672be282036 47baa997c443e40ae6519aae09b48fcc

# Other duplicate identities -- these have no relationships
delete_entity identities 179eae3982ab1e4047051381fb3b2e8d # argraves@musc.edu bialab
delete_entity identities 179eae3982ab1e4047051381fb3bd815 # crummerw@musc.edu crummewj
delete_entity identities 179eae3982ab1e4047051381fb42a819 # crummerw@musc.edu crummerw
delete_entity identities 179eae3982ab1e4047051381fbf1ba45 # polkp@musc.edu polkp
delete_entity identities 179eae3982ab1e4047051381fbf2aa17 # polkp@musc.edu polk
delete_entity identities 1e2bdf0ff9e85e9d4d8f9dad4acf73a7 # gilmanc@musc.edu gilmancs
delete_entity identities 1e2bdf0ff9e85e9d4d8f9dad4ad0011c # gilmanc@musc.edu gilmanc
delete_entity identities 1f5a4fd909e43d857d79220f75483c37 # cameronc@musc.edu fowlerc
delete_entity identities 1f5a4fd909e43d857d79220f754bccc1 # cameronc@musc.edu cameronc
delete_entity identities 1f5a4fd909e43d857d79220f7548466d # gainer@musc.edu gainer
delete_entity identities 1f5a4fd909e43d857d79220f754c50b3 # gainer@musc.edu gainer2
delete_entity identities 4fa16ff1a88ed2230bbc3a07ea754f51 # canteenn@musc.edu stanleyn
delete_entity identities 4fa16ff1a88ed2230bbc3a07ea75af71 # canteenn@musc.edu canteenn
delete_entity identities 4fa16ff1a88ed2230bbc3a07ea772a36 # bacrotr@musc.edu bacrotr
delete_entity identities 4fa16ff1a88ed2230bbc3a07ea7732d3 # bacrotr@musc.edu bacrotr2
delete_entity identities 572cd448493b45a4ea1fa6a476beb4a3 # kramerg@musc.edu stc4
delete_entity identities 572cd448493b45a4ea1fa6a476bec7eb # kramerg@musc.edu kramersg
delete_entity identities 6613aff69754eec596fbb67ff926a85f # brownlyn@musc.edu browncal
delete_entity identities 6613aff69754eec596fbb67ff92a9507 # brownlyn@musc.edu brownlyn
delete_entity identities 179eae3982ab1e4047051381fb41a428 # wisewc2@musc.edu wisewc

ruby find_invalid_service_requests.rb | delete_all
ruby find_invalid_service_request_relationships.rb | delete_all

