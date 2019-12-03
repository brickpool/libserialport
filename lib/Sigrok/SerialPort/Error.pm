package Sigrok::SerialPort::Error;

use strict;
use warnings;

use Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
  SET_ERROR
  last_error_code
  last_error_message
  is_debug
  set_debug
);

use MooseX::Params::Validate;
use English qw( -no_match_vars );
use Errno qw( :POSIX );

use Sigrok::SerialPort qw( :error );

##
#
# Errors
#
##

sub SET_ERROR {
  my ($err, $extended) = pos_validated_list( \@_,
    { isa => 'Maybe[Int]' },
    { isa => 'Int', optional => 1 },
  );
  $err = SP_ERR_FAIL unless defined $err;
  SWITCH: {
    ($err == SP_OK)       && do { $ERRNO = 0;       last SWITCH };
    ($err == SP_ERR_ARG)  && do { $ERRNO = EINVAL;  last SWITCH };
    ($err == SP_ERR_FAIL) && do { $ERRNO = EFAULT;  last SWITCH };
    ($err == SP_ERR_MEM)  && do { $ERRNO = ENOMEM;  last SWITCH };
    ($err == SP_ERR_SUPP) && do { $ERRNO = ENOSYS;  last SWITCH };
    {
      $ERRNO = $err;
    }
  }
  if ($extended) {
    $EXTENDED_OS_ERROR = $extended;
  } elsif ($err != SP_ERR_FAIL) {
    $EXTENDED_OS_ERROR = sp_last_error_code();
  }
  return 1;
}

sub last_error_code {
  return sp_last_error_code();
}

sub last_error_message {
  return sp_last_error_message();
}

my $_is_debug;

sub is_debug {
  return $_is_debug ? 1 : 0;
}

sub set_debug {
  my ($debug) = pos_validated_list( \@_,
    { isa => 'Bool' },
  );
  $debug = $debug ? 1 : 0;
  unless ($debug == is_debug) {
    sp_set_debug($debug);
    $_is_debug = $debug;
  }
  return $debug;
}

1;

__END__

=head1 NAME

Sigrok::SerialPort::Error - setting error and debugging information

=head1 SYNOPSIS

  use Sigrok::SerialPort::Error 'SET_ERROR';
  
  SET_ERROR(SP_OK);
  my $res = sp_get_lib_version_string();
  SET_ERROR(&Errno::EFAULT, 'undefined version string') unless $res;

=head1 DESCRIPTION

Most functions of the libserialport backend return an error values when there is
an error. This module transferred and stored these error values into the perl
variable C<$!>.

The error message is available via C<$!> in the case when an error was returned
by the previous function call. The error message returned by the OS, using the
current language settings from Errno module. The module redefine the error codes
of the libserialport return codes into the Error module error codes aquivalents.

=over 12

=item C<SP_OK>

The succeed return C<SP_OK> is equal to zero (C<$! = 0;>).

=item C<SP_ERR_ARG>

An invalid value was given for one of the arguments to a function. C<SP_ERR_ARG>
is mapped to C<EINVAL>: I<Invalid argument>.

=item C<SP_ERR_FAIL>

C<SP_ERR_FAIL> means that the OS reported a failure. C<SP_ERR_FAIL> is mapped to
C<EFAULT>: I<Bad address>.

=item C<SP_ERR_MEM>

C<SP_ERR_MEM> indicates that a memory allocation failed. C<SP_ERR_MEM> is mapped
to C<ENOMEM>: I<Out of memory>.

=item C<SP_ERR_SUPP>

C<SP_ERR_SUPP> indicates that there is no support for the requested operation in
the current OS, driver or device. C<SP_ERR_SUPP> is mapped to C<ENOSYS>: 
I<Function not implemented>.

=back

=head2 EXPORT

=over 12

=item C<SET_ERROR($err)>

=item C<SET_ERROR($err, $extended)>

The C<SET_ERROR> command is used to set the perl varaible C<$!> (or C<$^E>). The
parameter C<extended> is optional an can be used when a OS specific errno
constant is used for C<$^E>. C<SET_ERROR> has no return value.

  SET_ERROR(SP_OK);
  die $! if $!; # usually that does not happen

  SET_ERROR(SP_ERR_FAIL);
  print STDERR $! if $!;

  SET_ERROR(&Errno::EACCES);
  print STDERR $! if $!;

  SET_ERROR(SP_ERR_SUPP, last_error_code);
  print STDERR $^E if $^E;

=item C<last_error_code()>

The error code provided by the OS can be obtained by calling
C<last_error_code()>.

  print STDERR last_error_code();

=item C<last_error_message()>

The error message provided by the OS can be obtained by calling
C<last_error_message>.

  print STDERR last_error_message();

=item C<is_debug()>

Returns if the debug mode is enabled or not for the libserialport library.
Returns C<1> (TRUE) if the debug mode is enabled.

  $ret = is_debug();

=item C<set_debug(I<0|1>)>

Sets a flag if debug information shoud be printed while executing. The default
is not to debug (C<0>). Returns C<1> (TRUE) if debug or C<0> (FALSE) if not.

  print 'Debug enabled: ', set_debug(1);

=back

=head1 SEE ALSO

Please see those websites for more information related to the library API.

=over 4

=item *

L<Sigrok|http://sigrok.org/wiki/Libserialport>

=item *

L<github|https://github.com/sigrokproject/libserialport>

=back

=head1 SOURCE

Source repository is at L<https://github.com/brickpool/libserialport>.

=head1 AUTHOR

J. Schneider L<https://github.com/brickpool>

=head1 COPYRIGHT AND LICENSE

=over 4

=item *

Copyright (C) 2019 J. Schneider L<https://github.com/brickpool>

=back

This library is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
