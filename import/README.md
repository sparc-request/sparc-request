# Import Basics #

To do an import:

* Checkout `sparc-rails`, `obis-common`, and `migration_scripts` into
  the same directory.

* Run obis-common on port 4567:

        cd obis-common
        ruby script/run.rb

* Run `fix_database.sh` to update the existing database to the latest
  "schema".  This uses `migration_scripts`, which by default expects you
  to be running `obis-common` locally.

        ./fix_database.sh

* Run `delete.sh` to remove invalid entries from the couch database:

        ./delete.sh

* Run the import script:

        cd obis-bridge/import
        ./import.sh

The import process will:

* Create the sql database using `couch_crawler`
* Import all records (both entities and relationships) from the couch
  database into the sql database via the obisentity json interface
* Validate that all records have been imported successfully.

Note that this uses the `sparc_development` database by default.  As
there is no config file (yet), to point to a different database, you
will need to modify import.rb, `import_relationships.rb`, and
validate.rb with the correct database name and credentials.


# Importing documents #

The above import process will not import any documents.  To import
documents from an alfresco server:

* Create a config file in obis-bridge/import/config/alfresco.yml.  There
  is an example file that you can follow, or you can copy the file from
  an existing sparkling-lips installation.
* Edit `import_documents.rb` to point to the sql database.
* Run `import_documents.rb` to import the documents.

This will:

* Create documents in the sparc-rails/public directory
* Update the documents table in the database to point to the documents


# Importing notifications #

* Dump the notifications database into `notifier.sql`.

* Create a new notifications database:

        mysqladmin create notifications
        mysql
        > grant all privileges on notifications.* to 'notify'@'localhost' > identified by 'notify';

* Import:
* 
            mysql notifications --user=notify --password=notify < notifier.sql
            ruby import_notifications.rb


# What to do if the import process fails #

At each stage in the import process, the script will save the state of
the database into a `.sql` file.  You can fix the error and then restart
the import process at any point by using the -S option.  For example, to
restart the import, skipping all the way to importing relationships,
run:

    ./import.sh -S relationships

If you need to import only one entity (for testing purposes), you can
provide its obisid:

    ./import.sh -O <obisid>

