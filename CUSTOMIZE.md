# How to Customize SPARC
SPARC can be customized to meet the look and feel requirements for your institution. Customizable features include header images, CSS, displayable text, and the constants (which are used primarily for select lists and checkboxes). The example institution referenced in this doc is **uofexample (a.k.a., U of Example)**

## 1. Configure the Application
See the Multi-Institutional Doc for detailed instructions on configuring SPARCRequest to work for your institution.

## 2. Set Up a Second Project to Hold Customizations
A secondary project's directory structure is flexible but needs to be organized to fit with the Capistrano deployment. A sample directory structure using an institution named uofexample:

* /sparc-custom/
  * _piwik_tracking.html.haml (override MUSC analytics with your own)
  * constants-uofexample.yml
  * uofexample.yml
  * /assets/
      * /images/
        * /uofexample/ (your versions of these files, helps if they match MUSC's dimensions and file type)
          * about.png
        * account.png
        * department_name_460x60.gif
        * institution_logo_136x86.gif
        * org_logo_197x57.png
    * /stylesheets/
      * /uofexample/ (you can customize the CSS here)
        * application.scss
          * copy MUSC's version and update this file to reference bootstrap.min.css using: *= require ./bootstrap.min.css
        * bootstrap.min.css
        * /dashboard/
          * application.scss
            * copy MUSC's version and update this file as needed, starting with  *= require_tree ../../portal/ and *= require ./layout.sass
          * layout.sass

## 3. Customize
As the SPARC OS project continues to evolve, new CSS, images, constants, and display text will be added, updated, and removed. Thus, you'll want to review each OS release to see if your versions of these files need to be updated. Customize each file after copying it.

### 3.1 Locale
  cp /sparc-request/config/locales/en.yml /sparc-custom/uofexample.yml

### 3.2 Constants
  cp /sparc-request/config/constants.yml /sparc-custom/constants-uofexample.yml

### 3.3 CSS
  cp /sparc-request/app/assets/stylesheets/application.css    /sparc-custom/assets/stylesheets/uofexample/application.scss
  cp /sparc-request/app/assets/stylesheets/dashboard/application.scss /sparc-custom/assets/stylesheets/uofexample/dashboard/application.scss
  cp /sparc-request/app/assets/stylesheets/dashboard/layout.sass /sparc-custom/assets/stylesheets/uofexample/dashboard/layout.sass

## 4. Configure Developer Workstation
Create symbolic links from /sparc-request/ to your /sparc-custom/ project so that the sparc-request rails server can load your customizations. For example:

  ln -nfs /sparc-custom/_piwik_tracking.html.haml   /sparc-request/app/views/shared/_piwik_tracking.html.haml
  ln -nfs /sparc-custom/constants-uofexample.yml    /sparc-request/config/constants-uofexample.yml
  ln -nfs /sparc-custom/uofexample.yml        /sparc-request/config/locales/uofexample.yml
  ln -nfs /sparc-custom/assets/images/uofexample    /sparc-request/app/assets/images/uofexample
    ln -nfs /sparc-custom/assets/stylesheets/uofexample /sparc-request/app/assets/stylesheets/uofexample

## 5. Configure Capistrano Deployment
Wrap your Capistrano deployment within a process that first pulls the latest version of your /sparc-custom/ project, copies it to your server's /sparc-request/shared/ directory, and then starts the Capistrano deployment. In /config/deploy.rb, update the :symlink task to include your customizations:

  task :symlink do
      run "cp /<git checkout location>/sparc-custom/_piwik_tracking.html.haml /var/www/html/sparc/sparc-request/shared/."
      run "cp /<git checkout location>/sparc-custom/constants-uofexample.yml  /var/www/html/sparc/sparc-request/shared/."
      run "cp /<git checkout location>/sparc-custom/uofexample.yml      /var/www/html/sparc/sparc-request/shared/."
      run "cp -r /<git checkout location>/sparc-custom/assets         /var/www/html/sparc/sparc-request/shared/."

      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      run "ln -nfs #{shared_path}/config/setup_load_paths.rb #{release_path}/config/setup_load_paths.rb"
      run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
      run "ln -nfs #{shared_path}/config/ldap.yml #{release_path}/config/ldap.yml"
      run "ln -nfs #{shared_path}/config/epic.yml #{release_path}/config/epic.yml"
      run "ln -nfs #{shared_path}/constants-uofexample.yml #{release_path}/config/constants-uofexample.yml"
      run "ln -nfs #{shared_path}/uofexample.yml #{release_path}/config/locales/uofexample.yml"
      run "ln -nfs #{shared_path}/config/production.rb #{release_path}/config/environments/#{rails_env}.rb"
      run "ln -nfs #{shared_path}/assets/images/uofexample #{release_path}/app/assets/images/uofexample"
      run "ln -nfs #{shared_path}/assets/stylesheets/uofexample #{release_path}/app/assets/stylesheets/uofexample"
      run "ln -nfs #{shared_path}/_piwik_tracking.html.haml #{release_path}/app/views/shared/_piwik_tracking.html.haml"
  end

## 6. Contribute New Customizations
It will be difficult to upgrade to the latest release of the SPARC OS if your install includes custom changes. Instead, it is recommended that you contribute new features that will make it easier for all institutions to customize SPARC. One option is to create a new configuration parameter that will serve as a boolean switch to turn a new feature "on" but that will be "off" by default, so as to not affect the default install:

1. Add a new configuration parameter to application.yml that will turn a new feature on/off
2. Update /sparc-request/config/initializers/obis_setup.rb to parse the new configuration parameter into a global variable
3. Reference the global variable within the code assuming that by default the new feature will be "off"
