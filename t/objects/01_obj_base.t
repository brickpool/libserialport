use strict;
use Test::More tests => 13;

use Sigrok::SerialPort qw( :error );
use Sigrok::SerialPort::Base;
use Sigrok::SerialPort::Error qw( SET_ERROR );

my $sp = Sigrok::SerialPort::Base->new;
isa_ok $sp, 'Sigrok::SerialPort::Base';
undef $sp;

foreach ( @{ [
  SP_OK,              # 0
  SP_ERR_ARG,         # -1
  SP_ERR_FAIL,        # -2
  SP_ERR_MEM,         # -3
  SP_ERR_SUPP,        # -4
  &Errno::ENOENT,     # 2
  &Errno::ENXIO,      # 6
  &Errno::EBADF,      # 9
  &Errno::EACCES,     # 13
  &Errno::EFAULT,     # 14
  &Errno::ENODEV,     # 19
  &Errno::EOPNOTSUPP, # 95
] } ) {
  ok SET_ERROR($_), "SET_ERROR($_): $!";
}

done_testing;
