package MyL33tModules::SHA_HTTP_Auth;

# SHA_HTTP_Auth.pm
# Version 1.0
# Copyright 2013, by Joey Kelly
# joey@joeykelly.net
#
# This software is released under the GPL, version 2.
# See http://www.gnu.org/copyleft/gpl.html for details.

# This module is mostly cobbled together from example code and adapted to provide salted SHA
# (or any arbitrary hash and salt scheme the programmer wishes) for HTTP AUthentication.
# I could not find anything on the web that allowed the use of salted hashes,
# so I wrote something that did what I wanted.

# It can be argued that SHA_256 isn't strong enough (and I agree, it isn't),
# but since every page load, every image, etc. requires a database hit,
# speed becomes a deciding factor at some point. You may want to investigage caching options.
# YMMV.

# In order to make this work, you need to be running Apache and Mod_Perl2.
# This module needs to be in site_perl, vendor_perl or some other directory in your path.
# You can invoke the module via a stanza in httpd.conf, thusly:

# Alias /login /home/someusername/sites/securewwebapp/www/login
# <Directory "/home/someusername/sites/securewebapp/www/login">
#   DirectoryIndex index.pl
#   Options +Indexes +FollowSymLinks +MultiViews +ExecCGI -MultiViews +SymLinksIfOwnerMatch
#   Order allow,deny
#   allow from all
#   AuthType Basic
#   AuthName "SecureWebApp"
#   Require valid-user
#   <Files *.pl>
#   SetHandler perl-script
#   </Files>
#   PerlResponseHandler ModPerl::Registry
#   PerlAuthenHandler MyL33tModules::SHA_HTTP_Auth
#  </Directory>

# A sample database schema:
# CREATE TABLE user (
#   id                  INT           NOT NULL    AUTO_INCREMENT,
#   firstname           VARCHAR(20),
#   lastname            VARCHAR(20),
#   username            VARCHAR(20),
#   password            CHAR(64),
#   passwordsalt        INT,
#   ...
#   PRIMARY KEY(id)
# ) ENGINE=INNODB;



use strict;
#use warnings;

use Apache2::Access ();
use Apache2::RequestUtil ();
use Apache2::RequestRec ();
use Digest::SHA qw(sha256_hex);

use DBI;
# do I want to call back to a confile file? Not really...
my $dbhostname = 'localhost';
my $dbdatabase = 'SecureWebApp';
my $dbusername = 'someusername';
my $dbpassword = 'somepassword';
# change die to a meaningful error, with logging
our $dbh = DBI->connect("DBI:mysql:$dbdatabase:$dbhostname",$dbusername,$dbpassword) or die $DBI::errstr;

use Apache2::Const -compile => qw(OK DECLINED HTTP_UNAUTHORIZED);

sub handler {
  my $r = shift;

  my ($status, $pass) = $r->get_basic_auth_pw;
  chomp $pass;
  return $status unless $status == Apache2::Const::OK;

  my $user = $r->user();
  chomp $user;
  # NOTE: you really should sanitize the user's input before querying the database
  my $SQL = "SELECT count(*), username, password, passwordsalt from user where username = ?";
  my $cursor = $dbh->prepare($SQL);
  $cursor->execute($user);
  my @columns = $cursor->fetchrow;
  my ($count, $username, $password, $passwordsalt) = @columns;
  $cursor->finish;
  $dbh->disconnect;
  # anyone can prepend...
  my $saltedpass = $pass . $passwordsalt;
  my $passworddigest = sha256_hex($saltedpass);
  # let's make sure we have a unique user
  return Apache2::Const::OK if $count == 1 && $username eq $user && $password eq $passworddigest;

  $r->note_basic_auth_failure;
  return Apache2::Const::HTTP_UNAUTHORIZED;
}

1;
