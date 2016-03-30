-SHA_HTTP_Auth
==============

Mod_Perl HTTP Authentication module using salted SHA2

This module is mostly cobbled together from example code and adapted to provide salted SHA
(or any arbitrary hash and salt scheme the programmer wishes) for HTTP AUthentication.
I could not find anything on the web that allowed the use of salted hashes,
so I wrote something that did what I wanted.

It can be argued that SHA_256 isn't strong enough (and I agree, it isn't),
but since every page load, every image, etc. requires a database hit,
speed becomes a deciding factor at some point. You may want to investigage caching options.
YMMV.

In order to make this work, you need to be running Apache and Mod_Perl2.
This module needs to be in site_perl, vendor_perl or some other directory in your path.
You can invoke the module via a stanza in httpd.conf, thusly:

Alias /login /home/someusername/sites/securewebapp/www/login
<Directory "/home/someusername/sites/securewebapp/www/login">
  DirectoryIndex index.pl
  Options +Indexes +FollowSymLinks +MultiViews +ExecCGI -MultiViews +SymLinksIfOwnerMatch
  Order allow,deny
  allow from all
  AuthType Basic
  AuthName "SecureWebApp"
  Require valid-user
  <Files *.pl>
   SetHandler perl-script
  </Files>
  PerlResponseHandler ModPerl::Registry
  PerlAuthenHandler MyL33tModules::SHA_HTTP_Auth
</Directory>

A sample database schema:
CREATE TABLE user (
 id                  INT           NOT NULL    AUTO_INCREMENT,
 firstname           VARCHAR(20),
 lastname            VARCHAR(20),
 username            VARCHAR(20),
 password            CHAR(64),
 passwordsalt        INT,
 ...
 PRIMARY KEY(id)
) ENGINE=INNODB;
