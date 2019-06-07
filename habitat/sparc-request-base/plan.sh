# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

pkg_name=sparc-request
pkg_origin=sparc-request
pkg_version="3.1.0"
pkg_source="https://github.com/sparc-request/sparc-request/archive/${pkg_name}-${pkg_version}.tar.bz2"
# Overwritten later because we compute it based on the repo
pkg_shasum="b663cefcbd5fabd7fabb00e6a114c24103391014cfe1c5710a668de30dd30371"
pkg_deps=(
  core/libxml2
  core/libxslt
  core/libyaml
  core/mysql-client
  core/node
  core/curl
  core/rsync

  core/ruby/2.4.2
  core/bundler
  chrisortman/eye
  )
pkg_build_deps=(
  core/coreutils
  core/git
  core/gcc
  core/make
  core/which
  core/cacerts
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_svc_user="hab"
pkg_svc_group="$pkg_svc_user"

pkg_binds_optional=(
  [database]="port host"
)
pkg_exports=(
  [rails-port]=rails_port
)
pkg_exposes=(rails-port)

# Callback Functions
#
do_begin() {
  return 0
}

do_download() {
  export GIT_SSL_CAINFO="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"

  # This is a way of getting the git code that I found in the chef plan
  build_line "Fake download! Creating archive of latest repository commit from $PLAN_CONTEXT"
  cd $PLAN_CONTEXT/../..
  git archive --prefix=${pkg_name}-${pkg_version}/ --output=$HAB_CACHE_SRC_PATH/${pkg_filename} HEAD

  pkg_shasum=$(trim $(sha256sum $HAB_CACHE_SRC_PATH/${pkg_filename} | cut -d " " -f 1))
}

do_verify() {
  do_default_verify
  # return 0
}

# The default implementation removes the HAB_CACHE_SRC_PATH/$pkg_dirname folder
# in case there was a previously-built version of your package installed on
# disk. This ensures you start with a clean build environment.
do_clean() {
  do_default_clean
}

do_unpack() {
  do_default_unpack
  # return 0
}

do_prepare() {

  export BUNDLE_SILENCE_ROOT_WARNING=1

  build_line "Setting link for /usr/bin/env to 'coreutils'"
  [[ ! -f /usr/bin/env ]] && ln -s "$(pkg_path_for coreutils)/bin/env" /usr/bin/env

  # Need to make sure we can find bundler when we run rails / rake commands later
  export GEM_PATH="$(pkg_path_for "core/bundler"):$GEM_PATH"

  return 0
}

do_build() {

  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"
  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _zlib_dir=$(pkg_path_for zlib)
  local _openssl_include_dir=$(pkg_path_for openssl)

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  # we control the variable above, and it will be all on one line, and
  # we need single quotes otherwise the extconf doesn't build the
  # extension.
  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'

  # We need to add tzinfo-data to the Gemfile since we're not in an
  # environment that has this from the OS
   if ! grep -q 'gem .*tzinfo-data.*' Gemfile; then
     echo 'gem "tzinfo-data"' >> Gemfile
   fi

  # If you want rails console to work you need to
  # provide an implementation of readline
   if ! grep -q 'gem .*rb-readline.*' Gemfile; then
     echo 'gem "rb-readline"' >> Gemfile
   fi


   ####### ZOOM ######
   # If you want to speed up your habitat package build
   # while you're dev'ing do this after your first run
   # in the studio
   # cp -a /hab/cache/src/sparc-request-$pkg_version/vendor/bundle /hab/cache/src/bundle_cache
   # but you'll probably have to put the pkg version in there
   if [[ -e $HAB_CACHE_SRC_PATH/bundle_cache ]]; then
     echo "Restoring cached bundle install"
     cp -a $HAB_CACHE_SRC_PATH/bundle_cache vendor/bundle
   fi

   bundle install --path vendor/bundle --without test development --jobs 2 --retry 5 --binstubs --no-clean

  # cp -R vendor/bundle $HAB_CACHE_SRC_PATH/bundle_cache
  # Some bundle files when they install have permissions that don't
  # allow the all user to read them, but because we are running as
  # root right now for building, but as 'hab' or someone else when the
  # package installs we need to make sure we can read the files
  chmod -R a+rx vendor/bundle

  # Need to generate a database.yml if there isn't one
  if [[ ! -e config/database.yml ]]; then
    clean_up_db=true
    echo "Creating stub database.yml"
    cat << NULLDB > config/database.yml
production:
  adapter: nulldb
NULLDB

  fi

  if [[ ! -e config/epic.yml ]]; then
    echo "Copying default epic.yml for asset compilation"
    cp config/epic.yml.example config/epic.yml
  fi

  if [[ ! -e config/ldap.yml ]]; then
    echo "Copying default ldap.yml for asset compilation"
    cp config/ldap.yml.example config/ldap.yml
    sed -e "s#test#production#" -i "config/ldap.yml"
  fi

  RAILS_ENV=production bin/rake assets:precompile

  # need to clean up these yaml files
  rm config/epic.yml
  rm config/ldap.yml

}

# The default implementation runs nothing during post-compile. An example of a
# command you might use in this callback is make test. To use this callback, two
# conditions must be true. A) do_check() function has been declared, B) DO_CHECK
# environment variable exists and set to true, env DO_CHECK=true.
do_check() {
  return 0
}

# The default implementation is to run make install on the source files and
# place the compiled binaries or libraries in HAB_CACHE_SRC_PATH/$pkg_dirname,
# which resolves to a path like /hab/cache/src/packagename-version/. It uses
# this location because of do_build() using the --prefix option when calling the
# configure script. You should override this behavior if you need to perform
# custom installation steps, such as copying files from HAB_CACHE_SRC_PATH to
# specific directories in your package, or installing pre-built binaries into
# your package.
do_install() {

  # At this point my current directory is something
  # like /hab/cache/src/sparc-request-0.1.0
  # this the HAB CACHE SRC PATH or some such 
  # and in this directory I have a copy of my
  # rails app because this is where do_unpack would have
  # extracted my archive to.
  # The job of this task then is to get the files out of there
  # and put them someplace _useful_
  # Now the rails sample where I copied all this from
  # copies the files to pkg_prefix/release which I think can be 
  # thought of in the same vein as capistrano's releases folder?
  # so in order to not have new files overwriting existing files you
  # need something similar which for habitat is the package path because
  # that is all versioned out.
  # EDIT: I changed the cp -r to cp -a cuz maybe that's better
  # since I'm setting my user to hab up above anyway?
  echo "Copying current files to ${pkg_prefix}"
  mkdir -p "${pkg_prefix}/static/release"
  cp -a . "${pkg_prefix}/static/release"


  # This seems to be some habitat stuff that you 
  # just need to do?
  for binstub in ${pkg_prefix}/static/release/bin/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ruby)/bin/ruby#" -i "$binstub"
  done
  for binstub in ${pkg_prefix}/static/release/script/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ruby)/bin/ruby#" -i "$binstub"
  done

  if [[ $(readlink /usr/bin/env) = "$(pkg_path_for coreutils)/bin/env" ]]; then
    build_line "Removing the symlink we created for '/usr/bin/env'"
    rm /usr/bin/env
  fi

  chmod +x ${pkg_prefix}/static/release/script/upgrade/*.sh

  create_symlinks
}

create_symlinks() {

  rm -rfv ${pkg_prefix}/static/release/log
  rm -rfv ${pkg_prefix}/static/release/tmp
  rm -rfv ${pkg_prefix}/static/release/public/system
  rm -rfv ${pkg_prefix}/static/release/config/database.yml
  rm -rfv ${pkg_prefix}/static/release/config/application.yml
  rm -rfv ${pkg_prefix}/static/release/config/epic.yml
  rm -rfv ${pkg_prefix}/static/release/config/ldap.yml

  ln -sfv ${pkg_svc_var_path}/log ${pkg_prefix}/static/release/log
  ln -sfv ${pkg_svc_var_path}/tmp ${pkg_prefix}/static/release/tmp
  ln -sfv ${pkg_svc_data_path}/system ${pkg_prefix}/static/release/public/system

  ln -sfv ${pkg_svc_config_path}/database.yml ${pkg_prefix}/static/release/config/database.yml
  ln -sfv ${pkg_svc_config_path}/application.yml ${pkg_prefix}/static/release/config/application.yml
  ln -sfv ${pkg_svc_config_path}/epic.yml ${pkg_prefix}/static/release/config/epic.yml
  ln -sfv ${pkg_svc_config_path}/ldap.yml ${pkg_prefix}/static/release/config/ldap.yml
}

# The default implementation is to strip any binaries in $pkg_prefix of their
# debugging symbols. You should override this behavior if you want to change
# how the binaries are stripped, which additional binaries located in
# subdirectories might also need to be stripped, or whether you do not want the
# binaries stripped at all.
do_strip() {
  return 0
}

# There is no default implementation of this callback. This is called after the
# package has been built and installed. You can use this callback to remove any
# temporary files or perform other post-install clean-up actions.
do_end() {
  return 0
}

