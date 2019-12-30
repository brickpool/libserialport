##
# port of 'EASY PORTABLE SERIAL PORTS'
#
# Copyright (C) 2018 by Al Williams <https://hackaday.com/author/wd5gnr1/>
#
# https://hackaday.com/2018/09/14/easy-portable-serial-ports/
##
use strict;
use warnings;
use blib;
use Sigrok::SerialPort qw(:all);

use constant BAUD => 9600;
# Commands to LA
use constant USERCMD_RESET => '\0';
use constant USERCMD_RUN => '\1';
 
 
sub main
{
  my ($argc, @argv) = @_;
  my $port;
  my $err;
  my ($i,$cmd);
  my $count=4096;
# We need a serial port name
  if ($argc<2)
    {
    print(STDERR "Usage la port\n");
    exit(1);
    }
# Open serial port
  $err=sp_get_port_by_name($argv[1],\$port);
  if ($err==SP_OK) {
  $err=sp_open($port,SP_MODE_READ_WRITE); }
  if ($err!=SP_OK)
    {
    printf(STDERR "Can't open port %s\n",$argv[1]);
    exit(2);
    }
# set Baud rate
  sp_set_baudrate($port,BAUD);
 
# write reset
  $cmd=USERCMD_RESET;
  sp_blocking_write($port,$cmd,1,100);
# write run
  $cmd=USERCMD_RUN;
  sp_blocking_write($port,$cmd,1,100);
# read data 
  for ($i=0;$i<$count;$i++) 
    {
    my $waiting;
    my $c='\0';
    do 
      {
      $waiting=sp_input_waiting($port);
      } while ($waiting<=0);
# sort of inefficient -- could read a bunch of bytes at once
# could even block for all of them at once
    sp_nonblocking_read($port,\$c,1);
    if ($i%16==0) { printf("\n"); }
    printf("%02X ",ord($c));
    }
  print("\n");
  sp_close($port);
  return 0;
}

exit main( 1+@ARGV, $0, @ARGV );
