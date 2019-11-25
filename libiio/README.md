libserialport 0.1.1
===================

libserialport is a independent library that will be used by the
Sigrok::SerialPort project.

It is a minimal library written in C that is intended to take care of the
OS-specific details when writing software that uses serial ports.

The sources of libserialport are hosted on sigrok.org (sigrok uses
libserialport) and a prebuild defined library for windows is hosted on
analog.com (libiio uses libserialport).

INSTALLATION
------------

To install this library for Sigrok::SerialPort automatically, enter the
following:

  perl Makefile.PL
  make
  make install

PREPARE MANUALLY
----------------

If the automatic download or unpacking fails, the library can be prepared
manually for installation (Windows only):

  powershell.exe -Command "Invoke-WebRequest http://swdownloads.analog.com/cse/build/libiio-win-deps.zip -OutFile libiio-win-deps.zip"
  powershell.exe -Command "Expand-Archive -Force libiio-win-deps.zip"

Alternatively, you can download the library files from github and prepare as
follows (Windows only):

### (1) Get Header from github

  if not exist "include" mkdir include
  powershell.exe -Command "Invoke-WebRequest https://raw.githubusercontent.com/scottmudge/libserialport-cmake/master/libserialport.h -OutFile include/libserialport.h"
  
### (2) Get and prepare MSWin32 library Version

  powershell.exe -Command "Invoke-WebRequest https://github.com/analogdevicesinc/libiio/releases/download/v0.11/libiio-0.11.gcb2f40f-win32.zip -OutFile libiio.zip"
  powershell.exe -Command "Expand-Archive -Force libiio.zip"
  xcopy /Y libiio\libiio-win32\libserialport-0.dll libs\32\

  dlltool --as-flags=--32 -m i386 -z libs\32\libserialport-0.def --export-all-symbol libs\32\libserialport-0.dll
  perl -i.bak -ape "s/\t(?!sp_).*\n//s" libs\32\libserialport-0.def
  dlltool --as-flags=--32 -m i386 -d libs\32\libserialport-0.def -l libs\32\libserialport.dll.a -D libserialport-0.dll

### (3) Get MinGW-W64 build Version

  if not exist "include" mkdir libs\64\
  powershell.exe -Command "Invoke-WebRequest https://github.com/scottmudge/libserialport-cmake/raw/master/build_x64/libserialport.dll -OutFile libs\64\libserialport-0.dll"
  powershell.exe -Command "Invoke-WebRequest https://github.com/scottmudge/libserialport-cmake/raw/master/build_x64/libserialport.dll.a -OutFile libs\64\libserialport.dll.a"

### (4) Generate Archive

  xcopy /Y /S include\* libiio-win-deps\include\*
  xcopy /Y /S libs\* libiio-win-deps\libs\*
  if exist "libiio-win-deps.zip" del libiio-win-deps.zip
  powershell.exe -Command "Compress-Archive -Path libiio-win-deps\* -CompressionLevel Optimal -DestinationPath libiio-win-deps.zip"

DEPENDENCIES
------------

Windows precompiled DLL from Analog Devices Inc.

- <http://swdownloads.analog.com/cse/build/libiio-win-deps.zip>

SEE ALSO
--------

- <https://wiki.analog.com/resources/tools-software/linux-software/building_libiio_for_windows>
- <https://sigrok.org/wiki/Libserialport>
- <https://github.com/scottmudge/libserialport-cmake>

AUTHOR

* J. Schneider <http://github.com/brickpool>

COPYRIGHT AND LICENCE

* Copyright (C) 2013, 2015 Martin Ling <martin-libserialport@earth.li>
* Copyright (C) 2014 Uwe Hermann <uwe@hermann-uwe.de>
* Copyright (C) 2014 Aurelien Jacobs <aurel@gnuage.org>
* Copyright (C) 2016 Scott Mudge <mail@scottmudge.com>
* Copyright (C) 2016 Analog Devices Inc.

This library is free software: you can redistribute it and/or modify it under
the same terms of the GNU Lesser General Public License as published by Sigrok
and Analog Devices Inc.

Please refer to the Sigrok or Analog Devices Inc. homepage for a lot more
information.
