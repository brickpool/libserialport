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
use Carp;

use Sigrok::SerialPort qw( :error );

##
#
# Errors
#
##

sub SET_ERROR {
  my ($err, $msg) = pos_validated_list( \@_,
    { isa => 'Maybe[Int]' },
    { isa => 'Str', optional => 1 },
  );
  $err = SP_ERR_FAIL unless defined $err;
  if ($msg) {
    local $Carp::CarpLevel += 1;
    my $func = (caller($Carp::CarpLevel))[3] || 'main::__AMON__';
    Carp::carp sprintf("%s returning %d: %s", $func, $err, $msg);
  }
  for ($err) {
    if    ($_ == SP_OK)       { $ERRNO = 0                  } # when
    elsif ($_ == SP_ERR_ARG)  { $ERRNO = &Errno::EINVAL     } # when
    elsif ($_ == SP_ERR_FAIL) { $ERRNO = &Errno::EFAULT     } # when
    elsif ($_ == SP_ERR_MEM)  { $ERRNO = &Errno::ENOMEM     } # when
    elsif ($_ == SP_ERR_SUPP) { $ERRNO = &Errno::EOPNOTSUPP } # when
    else                      { $ERRNO = $_                 } # default
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

BEGIN {
  exists &Errno::EINVAL     and
  exists &Errno::EFAULT     and
  exists &Errno::ENOMEM     and
  exists &Errno::EOPNOTSUPP or
    die __PACKAGE__.' is not supported on this platform';
  set_debug($ENV{'LIBSERIALPORT_DEBUG'} ? 1 : 0);
}

1;
