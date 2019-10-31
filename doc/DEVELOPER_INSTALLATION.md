## SPARCRequest Installation Guide for Developers
### Install [Homebrew](https://brew.sh/)
Homebrew is a command-line tool that allows you to install other tools with ease.
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Install [Git](https://git-scm.com/)
Skip this step if you already have Git installed.

```
brew install Git
```

### Install [MySQL](https://www.mysql.com/)
MySQL is a tool that we use to manage our databases. While other tools exist and can be used with SPARC, MySQL is our go-to.
```
brew install mysql@5.7
brew link --force mysql@5.7

# Tell MySQL to start when you open Terminal
brew services start mysql@5.7
```

### Install [Node.js](https://nodejs.org/en/) and [Yarn](https://yarnpkg.com/en/)
Yarn is a tool built on the Node.js framework that allows you to easily create, manage, and share dependencies. SPARC uses Yarn to manage many of its JS and CSS assets from third-party libraries.
```
brew install node
brew install yarn
```

### Install [RVM](https://rvm.io/) to Manage Ruby Versions and Gemsets
RVM is a command-line tool which allows you to easily install, manage, and work with multiple Ruby environments from interpreters to sets of Ruby libraries - or *Gems*. 
```
# RVM relies on GPG
brew install gpg2

# Retrieve the authentication key via GPG
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
# Or if that fails:
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

# And install RVM:
curl -sSL https://get.rvm.io | bash -s stable --ruby
```

Close and re-open your terminal or run `source /Users/<yourprofile>/.rvm/scripts/rvm` to load RVM

### Clone the Repository
```
git clone https://github.com/sparc-request/sparc-request.git
cd sparc-request/
```

### Install a Local Ruby Version and Create a Project Gemset Using RVM
Every project relies on a specific version of Ruby and has a default name for its Gemset. These can be found in `.ruby-version` and `.gemset` respectively.
```
version=$(cat .ruby-version) && gemset=$(cat .gemset) && rvm install $version && rvm gemset create $gemset && rvm gemset use $gemset
```

### Install Gem Dependencies
We need to install several Gems that SPARC relies on to run properly. [Bundler](https://bundler.io/) is a Gem that we use to more easily install and manage other Gems. Gems are listed in `Gemfile` and their versions are stored in `Gemfile.lock`. Bundler uses this information to determine which Gems to install and which versions to use.
```
# Install bundler:
gem install bundler

# Install Gems:
bundle install
```

### Install Yarn Dependencies
We need to install several asset dependencies using Yarn very similar to how we installed Gems. Yarn lists dependencies in `package.json` and their versions in `package-lock.json`. Once installed, dependencies can be found in the `node_modules/` directory.
```
yarn install
```

### Copy Configuration Files
SPARC has several [YAML](https://yaml.org/) files that contain customizable configuration information. We store templates for these files using the `.example` extension. SPARC won't use these templates. We need to copy each template and create an equivalent file without the `.example` extension which can then be customized to suit your needs. These `.yml` files are ignored by Git.

The files SPARC uses are:
* `config/database.yml` - Contains information about how to connect to the database
* `config/ldap.yml` - (*Optional*) Can be used to store default values for LDAP-related Settings (see `doc/multi_institutional_documentation.md`) 
* `config/epic.yml` - (*Optional*) Can be used to store default values for Epic-related Settings (see `doc/multi_institutional_documentation.md`)
* `config/fulfillment_db.yml` - (*Optional*) Contains information about how to connect to the database of an external SPARCFulfillment environment
* `.env` - Contains miscellaneous environment-specific variablees
```
cp config/database.yml.example config/database.yml && cp config/ldap.yml.example config/ldap.yml && cp config/epic.yml.example config/epic.yml && cp config/fulfillment_db.yml.example config/fulfillment_db.yml && cp .env.example .env
```

### Create your Databases
You should have two databases - one for your development environment, and one for your test environment (for running Specs).
```
# Create your development Database
rake db:create && rake db:migrate

# Create your test Database
rake db:test:prepare
```

### Precompile Assets
Precompiling assets creates manifest files containing all of our internal and external assets that will be loaded instead of re-compiling assets on every server request. These precompiled assets are stored in the `public/assets/` directory. While your development server does not rely on precompiled assets, the test suite does in order to improve performance. Keep in mind that when changes are made to JS, CSS, or Image assets, or when Yarn dependencise are added or removed, you will want to recompile your assets before running Specs in order to update the manifest files.
```
rake assets:precompile
```

### Post-Installation
Now that you're done installing SPARC, we highly recommend reading through the *Multi-Institutional Documentation* (`multi_institutional_documentation.md`) to familiarize yourself with how SPARC uses **Settings** and **Permissible Values** for additional configuration. In particular, you will need to populate the `settings` and `permissible_values` tables for SPARC to work correctly.

```
# Populate Settings
rake data:import_settings

# Populate Permissible Values
rake:import_permissible_values
```