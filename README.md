[![NPM](https://nodei.co/npm/openldap_ssha.png)](https://npmjs.org/package/openldap_ssha)
[![Build Status](https://travis-ci.org/jmarca/openldap_ssha.svg?branch=master)](https://travis-ci.org/jmarca/openldap_ssha)


# SSHA (salted SHA passwords)


This is a utility library to use with openldap.  I originally wanted
to use bcrypt because I searched the internet too much, but on reading
the docs for openldap I discovered that the best available was "SSHA".

> This is the salted version of the SHA scheme. It is believed to be
> the most secure password storage scheme supported by
> slapd. <http://www.openldap.org/doc/admin24/security.html>

The code is mostly just an adaptation of the Perl code found at
<http://www.openldap.org/faq/data/cache/347.html>.  One of the tests
in fact checks the expected output of 'secret' with password 'salt'
against the output of the Perl program.

My application needs to use CAS  <http://www.jasig.org/cas> backed by
ldap, and so I cannot use anything other than the password schemes
supported out of the box by openldap.


# Tests

Four fairly simple tests have been added.  First whether 'secret' and
'salt' make the expected hash, then whether a random password and salt
can be encoded and decoded, whether non-ascii characters in the password
work and finally whether a known hash generated by slappasswd for the
password 'secret' can be properly verified.

I use mocha for the tests; `npm install` followed by `npm test` or
`make test` should run them.
