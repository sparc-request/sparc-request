# sparc-rails #

Rewrite of Backbone.js app to use Rails and MySQL

# deployment steps, some of these may be slightly different

Steps to install SPARC on existing instance

1. sudo su && useradd capistrano
2. add capistrano to rvm group (/etc/group)
3. su capistrano
4. rvm install ruby-1.9.3-p286
5. rvm use ruby-1.9.3-p286@sparc --create
6. cd ~ && mkdir .ssh
7. paste the following into .ssh/authorized_keys

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6ubhKtbq4OWq580MhjOm0YstRg00GS8djxwBqgwqUgPHU1DgROnrLnM72aF83oKZfH81RjdtFPnZ+OZxEDYVOVu6KFWMB/zY2BO4ZDdNfWDM21Ml2Y3A9cuQm+ViPMqR9FMX3l30UPcYkx15faTGWmds4bjG6TkGlNzexodSnqClla/lhF4MWPEu8YKD/Tsijyw5BnJUjIFrU/yK3sT7zTQwLr5sIz+xU6WxKKmYxf6ZOuxAE1V/Th1DA0vaU++szUaNy+ANtycwAn4DnsGQEnFFhUNHro6ye75Dbrvdt0u9cAybVyKTHOXl7R5NVEhMYnPLjBNvJo0Xg/bvtoQaxQ== amcates@Andrew-Catess-MacBook-Pro.local
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA14T02C6EwagE/kAi+lvnUPeU4w0YGK5M8qzRRfq4mSTMqv0LtIJPBxd406TdCUGtcGAtNqH5WapLWU7TQXlMc8jCfPehMkIwAL45FOoekbnU9D8eOy0nWart7adgf7gIPIU3LAiUZS26OxcWs3cohPAa/7oNxPF81SVhrbF5GdvqzqDqGDm9ylp2JxX2gPezRSwluip3EDFt315BRDty/mFQJbcQj11lQ848muGSKuTMr0xMttqKziP17sHL8viFzKaUXqVh1cTpImXt1GsVopoTXApqgWDdlPd0TQUzO7juYVnsDFbCi0N1dTwa//IVJovCG+ON3dEi+bsPv2WMpQ== mas244

8. chmod 700 .ssh
9. chmod 600 .ssh/authorized_keys
10. copy id_rsa from /home/capistrano/.ssh on obis-sparc-dev.mdc.musc.edu
11. chmod 600 .ssh/id_rsa
12. git clone git@github.com:HSSC/sparc-rails.git and make sure you can connect to git
13. rm -rf sparc-rails to removed the cloned directory
14. exit
15. rvm use ruby-1.9.3-p286@sparc --create (you should be root user now)
16. gem install passenger
17. yum install httpd httpd-devel curl-devel
18. exit to regular user and rvmsudo passenger-install-apache2-module
19. copy the following into /etc/httpd/conf.d/passenger.conf

   LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p286@sparc/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
   PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p286@sparc/gems/passenger-3.0.19
   PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p286@sparc/ruby

20. mkdir rails && chown capistrano:capistrano rails
21. vi /etc/httpd/conf.d/sparc.conf and paste the following

# Force SSL
NameVirtualHost *:80
<VirtualHost *:80>
    RewriteEngine on
    ReWriteCond %{SERVER_PORT} !^443$
    RewriteRule ^/(.*) https://%{HTTP_HOST}/$1 [NC,R,L]
</VirtualHost>
 
NameVirtualHost *:443
<VirtualHost *:443>
    # ------------------------------------------------------------------------------------ #
    # Virtual Server Basic Configuration
    # ------------------------------------------------------------------------------------ #
    ServerName obis-sparc3-v.musc.edu
    ServerAlias sparc.musc.edu
    ErrorLog logs/ssl_error_log
    TransferLog logs/ssl_access_log
    LogLevel warn

    # ------------------------------------------------------------------------------------ #
    # SSL Configuration
    # ------------------------------------------------------------------------------------ #
    SSLEngine on
    SSLProtocol all -SSLv2
    SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
    SSLCertificateFile /etc/pki/tls/certs/sparc.musc.edu.crt
    SSLCertificateKeyFile /etc/pki/tls/private/sparc.musc.edu.key
    SSLCertificateChainFile /etc/pki/tls/certs/InCommonServerCA.crt
    SetEnvIf User-Agent ".*MSIE.*" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0

    # ------------------------------------------------------------------------------------ #
    # Rails/SPARC Configuration
    # ------------------------------------------------------------------------------------ #

    DocumentRoot /var/www/rails/sparc-rails/current/public

    #PassengerLogLevel 3
    RackEnv production
    
    <Location /Shibboleth.sso>
      PassengerEnabled off
    </Location>
      
    <Directory /var/www/rails/sparc-rails/current/public>                                                                                    
      Allow from all                                                                                                                        
      Options -MultiViews                                                                                                                   
    </Directory>
      
    #sparc-rails auth
    <Location /identities/auth/shibboleth/callback>
      AuthType shibboleth
      ShibRequireSession On
      require valid-user
    </Location>
</VirtualHost>


22. su capistrano && cd /var/www/rails
23. FROM LOCAL: cap ENV deploy:setup
24. back on server, cd sparc-rails/shared && mkdir config
25. vi config/database.yml and add something like this

redh

26. vi config/application.yml and add something like this

staging:
  default_mail_to: 'glennj@musc.edu'
  admin_mail_to: 'success@musc.edu'
  user_portal_link: 'https://sparc-stg.mdc.musc.edu/portal/'

27. vi config/setup_load_paths.rb and add something like this

if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    gems_path = ENV['MY_RUBY_HOME'].split(/@/)[0].sub(/rubies/,'gems')
    ENV['GEM_PATH'] = "#{gems_path}:#{gems_path}@sparc"
    require 'rvm'
    RVM.use_from_path! File.dirname(File.dirname(__FILE__))
  rescue LoadError
    raise "RVM gem is currently unavailable."
  end
end

# If you're not using Bundler at all, remove lines bellow
ENV['BUNDLE_GEMFILE'] = File.expand_path('../DeployGemfile', File.dirname(__FILE__))
require 'bundler/setup'

28. switch back to root user

29. mysql create the database you specified in database.yml

30. FROM LOCAL: cap ENV deploy:cold

NOTE: had to yum install libxslt-devel

31. /etc/init.d/httpd configtest - if this is good you can proceed

32. /etc/init.d/httpd start

33. FROM LOCAL: cap ENV deploy

34. visit http://obis-sparc-rails-ENV.mdc.musc.edu and you should see the app

35. load data/documents

36. don't forget to install shibboleth, request ports that need to be opened, configure sendmail, get server white listed for smtp server, request any DNS changes
