Aker CAS CLI
============

Aker CAS CLI is a library that addresses a very specific problem: you
have a ruby application which uses a service that authenticates only
with CAS proxy tickets. You need to perform offline (non-interactive)
tasks that hit this PT-protected service.

Aker CAS CLI takes a username and password, screen-scrapes its way
through an interactive CAS login, and gives you an `Aker::User` just
as if a user of your application had done an interactive CAS login.

## Sample use

    # E.g., in a rake task in an Aker-protected Rails app
    task :some_job => :environment do |t|
      cas_cli = Aker::CasCli.new(Aker.configuration)
      username, password = get_username_and_password_from_somewhere
      user = cas_cli.authenticate(username, password)
      if user
        run_some_job_as(user)
      else
        fail "Could not authenticate #{user} for #{t.name}"
      end
    end

## Assumptions

* Your CAS server only requires a username and password. It doesn't
  use X509 certificates, two-factor authentication, or any additional
  custom fields on the login form.

## Use

Aker CAS CLI relies on the Aker CAS authority. The CAS authority must
be configured in the Aker::Configuration you pass to Aker CAS CLI. If
you're using Aker CAS CLI for a job implemented within your
Aker-protected application, the application's Aker configuration is
probably fine. This is what's used under "sample use," above.

Otherwise, you'll first need to create an appropriate Aker
configuration. Example:

    Aker.configure do
      authority :cas

      cas_parameters :cas_base_url => https://cas.myinst.edu/cas,
                     :proxy_retrieval_url => https://cas.myinst.edu/cas-callback/retrieve_pgt,
                     :proxy_callback_url => https://cas.myinst.edu/cas-callback/receive_pgt
    end

See [Aker's documentation][aker-doc] for more information about
configuring Aker, Aker authorities, etc.

[aker-doc]: http://rubydoc.info/gems/aker/file/README.md

## Why isn't Aker CAS CLI an Aker authority?

An Aker authority also has the form of a module/class providing a
method which takes a username and password, validates the pair, and
returns an Aker::User. However, Aker CAS CLI is _not_ intended to be
used as part of the security configuration for Aker-protected
applications. Aker provides features (multiple API modes, e.g.) which
should obviate the need to ever scrape a CAS server's interactive
login page as part of the regular operation of an Aker-protected
application. This library is for interacting with non-Aker-protected
services which have no alternatives to CAS PTs.

## Credits

Aker CAS CLI was developed at and for the [Northwestern University
Biomedical Informatics Center][NUBIC].

[NUBIC]: http://www.nucats.northwestern.edu/centers/nubic/index.html

### Copyright

Copyright (c) 2012 Rhett Sutphin. See LICENSE for details.
