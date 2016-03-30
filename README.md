-SHA_HTTP_Auth
==============

mod_perl HTTP Authentication module using salted SHA2

This module is mostly cobbled together from example code and adapted to provide salted SHA
(or any arbitrary hash and salt scheme the programmer wishes) for HTTP Authentication.
I could not find anything on the web that allowed the use of salted hashes,
so I wrote something that did what I wanted.

It can be argued that SHA_256 isn't strong enough (and I agree, it isn't),
but since every page load, every image, etc. requires a database hit,
speed becomes a deciding factor at some point. You may want to investigage caching options.
YMMV.

In order to make this work, you need to be running Apache and Mod_Perl2.
This module needs to be in site_perl, vendor_perl or some other directory in your path.
You can invoke the module via a stanza in httpd.conf, details of which are shown in the module itself.

The beauty of using HTTP Authentication (for me, at least) is that the user, having authenticated to our Apache webserver, is known and authorized to use the site (a simple "my $user = $r->user();" statement tells us exactly who is accessing our site). This is not to say, of course, that CSRF and other precautions should not be taken. This module also insures that if our database is stolen, the bad guys have to deal with salted password hashes (hopefully the programmer has insured unique salts).
