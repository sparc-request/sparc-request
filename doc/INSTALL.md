Hardware recommendations:
2 CPUs
4gb of memory
50gb of hard disk space (things to consider: # of documents per service request and size of mysql instance)

Software requirements:
  apache (sometimes referred to as httpd)
  apache-devel (sometimes referred to as httpd-devel)
  curl-devel
  mysql
  ruby (see .ruby-version)
  rubygems

From a brand new server:
- Install Apache
- Install MySQL
- Install Node.js
- Install Yarn
- Install the dependencies for Ruby
- Install Ruby either from source or by using RVM (instructions for installing RVM can be found at rvm.io)
- Verify that ruby is the correct version, ruby –version
- Clone the git repository to a location on the server (/var/www/rails is a good location)

- Depending on the environment that is configured (staging/production/testing/etc) go into the application folder and run
- yarn install
- RAILS_ENV=environment_chosen bundle install
- RAILS_ENV=environment_chosen rake db:create
- RAILS_ENV=environment_chosen rake db:migrate
- Set the application configurations to your liking (stored in 'settings' table)
- Install the phusion passenger gem: gem install passenger
- Install the passenger apache module: passenger-install-apache2-module
- Follow the instructions provided by the passenger apache module install script.
- Create a virtualhost entry for the application which points to the public folder (so if your app is at /var/www/rails/sparc-rails then the DocumentRoot and Directory should be /var/www/rails/sparc-rails/public)
- You will need to set:
- Options -MultiViews
- And (depending on your settings) you may need to set:
- AllowOverride all
- Allow from all
- Depending on your settings you may need to chmod the application directory (I had to chmod -R 777 the directory to get write permissions for log and cache files to work with apache)
- Restart apache

The application can easily be setup to deploy using Capistrano or any other automated deployment method.  RVM can also be used to manage the ruby versions used.  See doc/musc_installation_example.txt for an example.

Once the Installation is complete you will need to create your initial institution and user.  To do this follow these steps:

- While in the application folder (if the examples here were followed then /var/www/rails/sparc-rails) run the command: RAILS_ENV=chosen_environment rails console (where chosen_environment is the environment whose database you want to access)
- Once in the console enter: require ‘./app/lib/initial_cm_creation’,  then enter: ‘run_initial_setup’ and follow the instructions.
- NOTE: This tool should only be used to set up your initial institution and user, as it creates users with admin privileges.

Once you have created an initial institution and set yourself as a catalog manager, you will be able to access the catalog manager part of the application and begin inputing your organizational structure and service offerings. This tool can be found at <root_url>/catalog_manager. In order to access administrative options for a particular request within the dashboard, you will need to either be a service provider or a super user for the organizational level of the services in that request. These rights can be granted in the catalog manager under the ‘Service Providers’ and ‘Super Users’ sections for each organizational entity.

Some basic important URLs for the application are as follows:
<root_url> - The main SPARCRequest shopping screen
<root_url/dashboard> - The SPARCRequest Dashboard
<root_url/catalog_manager> - The Catalog Manager application for managing organizational structure and service offerings
<root_url/reports> - The SPARCRequest reporting module

