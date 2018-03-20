# Habitat Documentation

## Current Status

SPARC installs as a single habitat package.

All of the habitat stuff is in the `habitat/sparc-request-base` folder.

[Puma](http://puma.io) is used as the webserver and [delayed_job](https://github.com/collectiveidea/delayed_job)
is used for background processing.

Habitat starts the [eye](https://github.com/kostya/eye) process monitor which starts puma and delayed_job.

The rails application code will be installed to the `/hab/pkgs/....` directory with symlinks for `log`, `tmp`, 
and `public/system` (file uploads) created pointing to `/hab/svc/sparc-request`

| app path | real path |
| ---------|-----------|
| log | /hab/svc/sparc-request/var/log |
| tmp | /hab/svc/sparc-request/var/tmp |
| public/system | /hab/svc/sparc-request/data |

The `application.yml`, `ldap.yml`, `epic.yaml`, and `database.yml` files are symlinked to point to `/hab/svc/sparc-request/config`

Eye runtime data is stored in `/hab/svc/sparc-request/var/.eye`
Puma output is logged to `/hab/svc/sparc-request/var/log/puma.log`
Delayed Job output is logged to `/hab/svc/sparc-request/var/log/dj-N.log`


## Commands

### OPS

- Install SPARC: `hab pkg install sparc-request/sparc-request`
- Start SPARC: `hab start sparc-request/sparc-request`
- Cause migrations & database tasks to run the next time the package is started: `mkdir -p /hab/svc/sparc-request/data/migrate && touch /hab/svc/sparc-request/data/migrate`
- Follow the web process log: `less -R +F /hab/svc/sparc-request/var/log/puma.log`
- Follow the delayed_job log: `less -R +F /hab/svc/sparc-request/var/log/dj-1.log`
- To customize configuration `mkdir -p /hab/user/sparc-request/config && cp $(hab pkg path sparc-request/sparc-request)/default.toml /hab/user/sparc-request/config/user.toml` . Now you make your changes in `user.toml` and they override `default.toml` **requires habitat version > 0.52** 

In order to run `eye` or `rails` commands you need to source the environment.

`. /hab/svc/sparc-request/config/dotenv`

- Get info of running services: `leye info`
- Rails console: `cd $RAILS_ROOT && bin/rails c`


### Development

*eye is not part of the bundle, `gem install eye` to use it*

- Test eye config: `eye load habitat/sparc-request-base/config/sparc.eye -f`

## Changes

### 2017-11-17
The architecture of the habitat packages changed from three packages to one package in order to simplify the update process.

The habitat supervisor detects when a new version of a package is available and will download and update it locally, _but_ 
because of how we were structured we could get into race conditions and updates being downloaded but not applied because 
the update process does no cooridination with dependent services.

The deployment process also changed from copying all of the rails code down to the `/hab/svc/sparc-request` directory so that
start up time is much faster.

## Known Issues

### 2017-11-17

In habitat version 38 (possibly others) running a studio inside a linux vm is broken. So be cautious about using the
vagrant box for package development. I have been building packages in the docker habitat studio on my mac and then
installing them inside the vagrant VM to test. The primary reason to install inside the VM at this point is because
it is simpler to have the `MySql` server running as a service than a habitat package inside the studio. -- CO-UIOWA

## FAQ

**Q.** Why are you using a process monitor?

**A.** 

delayed_job and puma both need to operate on the same set of ruby files **and** have the same configuration. Because we
are letting habitat control some of this configuration (that's the `habitat/config/**` file copies) those files won't
have their variables replaced until a service is **started**. The config files in `/hab/pkgs/***` are templates and they
need variables expanded. When that happens the config files go to `/hab/svc/**`

Either the delayed_job service and web service have to have their own copies of all of the files   **or** they have to
have a common set that they share.

I do not think you can have the delayed_job service _depend on_ the web service you'll have a race condition or you might
as well have them be in a single because you could never run the delayed_job service on another server without also running
the web service on that server which seems like it would be the main reason to separate them anyway.

So your other option is what we did before which was to have a common _base_ package that handles all the files. But this
has the problem of you still need that base to _run_ so your config files get generated but it doesn't do anything and
is why the old way I did it was to have the run hook `sleep infinity`. But now you have the race condition on updates where
you need the init hook of the base package to run and after it's done then the other services get restarted but habitat
doesn't work that way.

**Q.** Why use `eye` and not `god`, `bluepill`, `foreman`, `monit`?

**A.** 

Of all of those choices, `eye` was the only one that has a mode that shuts down all the processes when
the eye process stops. This is the behavior we want because it is consistent with what the habitat
supervisor does where if you kill the supervisor everything else stops too.

**Q.** What about habitat composite packages?

**A.**

They don't (as of 2017-11-17) address update coordination

**Q.** What sort of stuff should I test with my deployment

1. Do file uploads work and can the files be downloaded? There's lot's of places that permissions could get missed along this path

