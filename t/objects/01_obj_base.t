use strict;
use Test::More tests => 14;
use Errno qw( :POSIX );

use Sigrok::SerialPort qw( :error );
use Sigrok::SerialPort::Base;
use Sigrok::SerialPort::Error qw( SET_ERROR );

my $sp = Sigrok::SerialPort::Base->new;
isa_ok $sp, 'Sigrok::SerialPort::Base';
undef $sp;

foreach ( @{ [
  SP_OK,        # 0
  SP_ERR_ARG,   # -1
  SP_ERR_FAIL,  # -2
  SP_ERR_MEM,   # -3
  SP_ERR_SUPP,  # -4
  ENOENT,       # 2
  EINTR,        # 4
  ENXIO,        # 6
  EBADF,        # 9
  EFAULT,       # 14
  ENODEV,       # 19
  EINVAL,       # 22
  EPIPE,        # 32
] } ) {
  ok SET_ERROR($_), "SET_ERROR($_): $!";
}

done_testing;
