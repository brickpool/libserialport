package Sigrok::SerialPort::List;

use Moose;

use Sigrok::SerialPort::List::Ports;

extends 'Sigrok::SerialPort::Base';

has 'ports' => (
  is        => 'ro',
  isa       => 'Sigrok::SerialPort::List::Ports',
  required  => 1,
  init_arg  => 'undef',
  default   => sub { Sigrok::SerialPort::List::Ports->new },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sigrok::SerialPort::List - obtaining a list of serial ports on the system

=head1 SYNOPSIS

  use Sigrok::SerialPort::List;
  
  my $list;
  eval { $list = Sigrok::SerialPort::List->new }
    or die $@;
  foreach my $port ( $list->ports->elements ) {
    print 'Port found: ', $port->get_name(), "\n";
  }

=head1 DESCRIPTION

List the serial ports available on the system. The result obtained is an array
of port objects. The C<List> object use an attribute of type
C<Sigrok::SerialPort::List::Ports> to store the array. You shound use the
accessor C<ports> to get access to the array.

The object should be destroyed after use. If a port from the list is to be used
after destroying the list object, it must be copied first.

If any error is occured, the perl variable C<$!> will be set.

=head2 EXPORT

=over 12

=item C<new()>

The constructor C<new> will be called without attributes. If any error is
occurred, an exception will be thrown.

  my $list = new Sigrok::SerialPort::List;

What's the easiest way to get the first port?

  my $port0;
  eval { $port0 = Sigrok::SerialPort::List->new->ports->get(0) }
    or die @_;
  print 'First port: ', $port0->get_name();

=item C<ports()>

This method provides a get accessor for the array, based on an array reference
of type C<Sigrok::SerialPort::List::Ports>.

  foreach my $port ( $list->ports->elements ) {
    print 'Found port: ', $port->get_name(), "\n";
  }
  die 'Error finding serial device' if $list->ports->is_empty;
  print 'First port: ', $list->ports->get(0)->get_name, "\n";
  print 'Number of ports: ', $list->ports->count, "\n";

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
