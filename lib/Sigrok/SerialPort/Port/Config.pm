package Sigrok::SerialPort::Port::Config;

use Moose;
use MooseX::Params::Validate;
use Carp qw( croak );
use English qw( -no_match_vars );

use Sigrok::SerialPort qw(
  SP_OK

  sp_new_config
  sp_free_config
  sp_get_config
  sp_set_config
  sp_set_baudrate
  sp_get_config_baudrate
  sp_set_config_baudrate
  sp_get_config_bits
  sp_set_config_bits
  sp_get_config_parity
  sp_set_config_parity
  sp_get_config_stopbits
  sp_set_config_stopbits
  sp_get_config_rts
  sp_set_config_rts
  sp_get_config_cts
  sp_set_config_cts
  sp_get_config_dtr
  sp_set_config_dtr
  sp_get_config_dsr
  sp_set_config_dsr
  sp_get_config_xon_xoff
  sp_set_config_xon_xoff
  sp_set_config_flowcontrol

  sp_last_error_message
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
);

extends 'Sigrok::SerialPort::Base';

##
#
# Configuration
#
##

has 'config_handle' => (
  isa       => 'sp_port_config',
  required  => 1,
  lazy      => 1,
  init_arg  => 'handle',
  reader    => 'get_handle',
  # private methods
  builder   => '_build_handle',
);

has 'baudrate' => (
  isa       => 'Maybe[sp_baudrate]',
  reader    => 'get_baudrate',
  writer    => 'set_baudrate',
  # private methods
  trigger   => \&_trigger_baudrate,
);

has 'bits' => (
  isa       => 'Maybe[sp_databits]',
  reader    => 'get_bits',
  writer    => 'set_bits',
  # private methods
  trigger   => \&_trigger_bits,
);

has 'parity' => (
  isa       => 'Maybe[sp_parity]',
  reader    => 'get_parity',
  writer    => 'set_parity',
  # private methods
  trigger   => \&_trigger_parity,
);

has 'stopbits' => (
  isa       => 'Maybe[sp_stopbits]',
  reader    => 'get_stopbits',
  writer    => 'set_stopbits',
  # private methods
  trigger   => \&_trigger_stopbits,
);

has 'rts' => (
  isa       => 'Maybe[sp_rts]',
  reader    => 'get_rts',
  writer    => 'set_rts',
  # private methods
  trigger   => \&_trigger_rts,
);

has 'cts' => (
  isa       => 'Maybe[sp_cts]',
  reader    => 'get_cts',
  writer    => 'set_cts',
  # private methods
  trigger   => \&_trigger_cts,
);

has 'dtr' => (
  isa       => 'Maybe[sp_dtr]',
  reader    => 'get_dtr',
  writer    => 'set_dtr',
  # private methods
  trigger   => \&_trigger_dtr,
);

has 'dsr' => (
  isa       => 'Maybe[sp_dsr]',
  reader    => 'get_dsr',
  writer    => 'set_dsr',
  # private methods
  trigger   => \&_trigger_dsr,
);

has 'xon_xoff' => (
  isa       => 'Maybe[sp_xonxoff]',
  reader    => 'get_xon_xoff',
  writer    => 'set_xon_xoff',
  # private methods
  trigger   => \&_trigger_xon_xoff,
);

has 'flowcontrol' => (
  isa       => 'Maybe[sp_flowcontrol]',
  writer    => 'set_flowcontrol',
  # private methods
  trigger   => \&_trigger_flowcontrol,
);

##
#
# extends accessor methods
#
##

around 'get_baudrate' => sub {
  my ($next, $self) = @_;
  $self->{baudrate} = $self->_get_config_baudrate;
  return $self->$next;
};

around 'get_bits' => sub {
  my ($next, $self) = @_;
  $self->{bits} = $self->_get_config_bits;
  return $self->$next;
};

around 'get_parity' => sub {
  my ($next, $self) = @_;
  $self->{parity} = $self->_get_config_parity;
  return $self->$next;
};

around 'get_stopbits' => sub {
  my ($next, $self) = @_;
  $self->{stopbits} = $self->_get_config_stopbits;
  return $self->$next;
};

around 'get_rts' => sub {
  my ($next, $self) = @_;
  $self->{rts} = $self->_get_config_rts;
  return $self->$next;
};

around 'get_cts' => sub {
  my ($next, $self) = @_;
  $self->{cts} = $self->_get_config_cts;
  return $self->$next;
};

around 'get_dtr' => sub {
  my ($next, $self) = @_;
  $self->{dtr} = $self->_get_config_dtr;
  return $self->$next;
};

around 'get_dsr' => sub {
  my ($next, $self) = @_;
  $self->{dsr} = $self->_get_config_dsr;
  return $self->$next;
};

around 'get_xon_xoff' => sub {
  my ($next, $self) = @_;
  $self->{xon_xoff} = $self->_get_config_xon_xoff;
  return $self->$next;
};

##
#
# extends default methods
#
##

sub DEMOLISH {
  my $self = shift;
  $self->_free_config if $self->get_handle
}

##
#
# additional public methods
#
##

sub cget
{
  my $self = shift;
  my ($param) = pos_validated_list( \@_,
    { isa => 'Str' },
  );
  $param =~ s/^\b/\-/;  # option => -option
  my $ret_val;
  for ($param) {
    if    (/^-baudrate$/) { $ret_val = $self->get_baudrate; } # when
    elsif (/^-bits$/    ) { $ret_val = $self->get_bits;     } # when
    elsif (/^-parity$/  ) { $ret_val = $self->get_parity;   } # when
    elsif (/^-stopbits$/) { $ret_val = $self->get_stopbits; } # when
    elsif (/^-rts$/     ) { $ret_val = $self->get_rts;      } # when
    elsif (/^-cts$/     ) { $ret_val = $self->get_cts;      } # when
    elsif (/^-dtr$/     ) { $ret_val = $self->get_dtr;      } # when
    elsif (/^-dsr$/     ) { $ret_val = $self->get_dsr;      } # when
    elsif (/^-xon_xoff$/) { $ret_val = $self->get_xon_xoff; } # when
    else                  {                                   # default
      croak "Validation failed for 'option' with value $_ " .
            "(-baudrate|-bits|-parity|-stopbits|-rts|-cts|-dtr|-dsr|-xon_xoff) is required";
    }
  }
  return $ret_val;
}

sub configure
{
  my $self = shift;
  return qw('-baudrate' '-bits' '-parity' '-stopbits' '-rts' '-cts' '-dtr' '-dsr' '-xon_xoff') unless @_;
  my (%options) = validated_hash( \@_,
    '-baudrate'    => { isa => 'sp_baudrate',    optional => 1 },
    '-bits'        => { isa => 'sp_databits',    optional => 1 },
    '-parity'      => { isa => 'sp_parity',      optional => 1 },
    '-stopbits'    => { isa => 'sp_stopbits',    optional => 1 },
    '-rts'         => { isa => 'sp_rts',         optional => 1 },
    '-cts'         => { isa => 'sp_cts',         optional => 1 },
    '-dtr'         => { isa => 'sp_dtr',         optional => 1 },
    '-dsr'         => { isa => 'sp_dsr',         optional => 1 },
    '-xon_xoff'    => { isa => 'sp_xonxoff',     optional => 1 },
    '-flowcontrol' => { isa => 'sp_flowcontrol', optional => 1 },
  );
  SET_ERROR(SP_OK);
  {
    $self->set_baudrate     ( $options{'-baudrate'}     ) if $options{'-baudrate'};
    return undef if $ERRNO;
    $self->set_bits         ( $options{'-bits'}         ) if $options{'-bits'};
    return undef if $ERRNO;
    $self->set_parity       ( $options{'-parity'}       ) if $options{'-parity'};
    return undef if $ERRNO;
    $self->set_stopbits     ( $options{'-stopbits'}     ) if $options{'-stopbits'};
    return undef if $ERRNO;
    $self->set_rts          ( $options{'-rts'}          ) if $options{'-rts'};
    return undef if $ERRNO;
    $self->set_rts          ( $options{'-cts'}          ) if $options{'-cts'};
    return undef if $ERRNO;
    $self->set_rts          ( $options{'-dtr'}          ) if $options{'-dtr'};
    return undef if $ERRNO;
    $self->set_rts          ( $options{'-dsr'}          ) if $options{'-dsr'};
    return undef if $ERRNO;
    $self->set_xon_xoff     ( $options{'-xon_xoff'}     ) if $options{'-xon_xoff'};
    return undef if $ERRNO;
    $self->set_flowcontrol  ( $options{'-flowcontrol'}  ) if $options{'-flowcontrol'};
    return undef if $ERRNO;
  }
  return 1;
}

##
#
# private build methods
#
##

sub _build_handle
{
  my $self = shift;
  my $ret_val;
  my $ret_code = sp_new_config(\$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return 0;
  }
  unless ($ret_val > 0) {
    SET_ERROR(&Errno::EFAULT, 'Bad address');
    return 0;
  }
  return $ret_val;
}

##
#
# private trigger methods
#
##

sub _trigger_baudrate
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_baudrate' },
    { isa => 'sp_baudrate', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_baudrate($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_bits
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_databits' },
    { isa => 'sp_databits', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_bits($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_parity
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_parity' },
    { isa => 'sp_parity', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_parity($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_stopbits
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_stopbits' },
    { isa => 'sp_stopbits', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_stopbits($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_rts
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_rts' },
    { isa => 'sp_rts', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_rts($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_cts
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_cts' },
    { isa => 'sp_cts', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_cts($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_dtr
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dtr' },
    { isa => 'sp_dtr', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_dtr($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_dsr
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dsr' },
    { isa => 'sp_dsr', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_dsr($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_xon_xoff
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_xonxoff' },
    { isa => 'sp_xonxoff', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_xon_xoff($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_flowcontrol
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_flowcontrol' },
    { isa => 'sp_flowcontrol', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_set_config_flowcontrol($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

##
#
# private backend wrapper methods
#
##

sub _get_config_baudrate {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_baudrate($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_bits {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_bits($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_parity {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_parity($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_stopbits {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_stopbits($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_rts {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_rts($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_cts {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_cts($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dtr {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_dtr($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dsr {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_dsr($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_xon_xoff {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  my $ret_code = sp_get_config_xon_xoff($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _free_config
{
  my $self = shift;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  sp_free_config($self->get_handle);
  SET_ERROR(SP_OK);
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
