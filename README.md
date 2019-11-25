SerialPort version 0.02
=======================

Perl wrapper for the `libserialport` C library.

All essential functions of the entire library API are wrapped by using `XS`.
In addition, a higher-level OOP interface is also provided by using `Moose`.

The library could build only on Windows and should work on Windows and
Unix-based systems. If it does not, please submit a Issue.

ALPHA WARNING
-------------

This stuff is all still pretty new and I may break it while working on it,
I may break compatibility with any given commit.

INSTALLATION
------------

To install this module type the following:

  perl Makefile.PL
  make
  make test
  make install

DEPENDENCIES
------------

This module requires these other modules and libraries:

- Moose
- MooseX::Params::Validate
- libserialport

The `examples/` directory contains simple serial programs by using the
`Sigrok::SerialPort::Backend` module.

SEE ALSO
--------

- <https://sigrok.org/wiki/Libserialport>
  
AUTHOR
------

* J. Schneider <http://github.com/brickpool>

COPYRIGHT AND LICENCE
---------------------

libserialport is an open source project released under the LGPL3+ license.

* Copyright (C) 2013, 2015 Martin Ling <martin-libserialport@earth.li>
* Copyright (C) 2014 Uwe Hermann <uwe@hermann-uwe.de>
* Copyright (C) 2014 Aurelien Jacobs <aurel@gnuage.org>

This Module is free software: you can redistribute it and/or modify it under
the same terms of the GNU Lesser General Public License as published by
libserialport.

Please refer to the Sigrok homepage for a lot more information.
