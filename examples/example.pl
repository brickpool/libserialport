##
# port of 'libserialport example.c'
#
# Copyright (C) 2019 by Callum Bryant <callum@see-bry.com>
#
# https://gist.github.com/Nixes/78e401234e66aa131547d7b78135271c
##
use strict;
use warnings;
use blib;

use IO::Handle;
use Time::HiRes qw(sleep);  # for sleep function

# cross platform serial port lib
use Sigrok::SerialPort qw(:all);

my $desired_port = "COM3";

my $port;

sub list_ports {
  my $i;
  my @ports;

  my $error = sp_list_ports(\@ports);
  if ($error == SP_OK) {
    for ($i = 0; $ports[$i]; $i++) {
      printf("Found port: '%s'\n", sp_get_port_name($ports[$i]));
    }
    sp_free_port_list(@ports);
  } else {
    printf("No serial devices detected\n");
  }
  printf("\n");
}

sub parse_serial {
  my @byte_buff = unpack('(C2)'.$_[1], $_[0]);
  my $byte_num = $_[1];
  for (my $i = 0; $i < $byte_num; $i++) {
    printf("%c", $byte_buff[$i]);
  }
  printf("\n");
}

sub main {
  list_ports();

  printf("Opening port '%s' \n", $desired_port);
  my $error = sp_get_port_by_name($desired_port, \$port);
  if ($error == SP_OK) {
    $error = sp_open($port, SP_MODE_READ);
    if ($error == SP_OK) {
      sp_set_baudrate($port, 57600);
      while (1) {

        sleep(0.5); # can do something else in mean time
        my $bytes_waiting = sp_input_waiting($port);
        if ($bytes_waiting > 0) {
          printf("Bytes waiting %i\n", $bytes_waiting);
          my $byte_buff = '\0' x 512;
          my $byte_num = 0;
          $byte_num = sp_nonblocking_read($port, \$byte_buff, 512);
          parse_serial($byte_buff, $byte_num);
        }
        STDOUT->flush();
      }

      sp_close($port);
    } else {
      printf("Error opening serial device\n");
    }
  } else {
    printf("Error finding serial device\n");
  }

  return 0;
}

exit main( @ARGV );
