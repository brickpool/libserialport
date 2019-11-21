use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Base;

{
  my $sp = Sigrok::SerialPort::Base->new;
  isa_ok $sp, 'Sigrok::SerialPort::Base';
  is $sp->return_code, SP_OK, "return_code";
  is $sp->exit_status, SP_OK, "exit_status";
  ok $sp->is_ok, "is_ok";
  undef $sp;
}

done_testing;
