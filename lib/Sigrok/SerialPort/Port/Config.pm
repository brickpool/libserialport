package Sigrok::SerialPort::Port::Config;

use Moose;
use MooseX::Params::Validate;
use Carp qw( croak );

use Sigrok::SerialPort qw( SP_ERR_ARG );
use Sigrok::SerialPort::Backend qw(
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
  predicate => '_has_handle',
  builder   => '_build_handle',
);

has 'baudrate' => (
  isa       => 'sp_baudrate',
  reader    => 'get_baudrate',
  writer    => 'set_baudrate',
  # private methods
  trigger   => \&_trigger_baudrate,
);

has 'bits' => (
  isa       => 'sp_databits',
  reader    => 'get_bits',
  writer    => 'set_bits',
  # private methods
  trigger   => \&_trigger_bits,
);

has 'parity' => (
  isa       => 'sp_parity',
  reader    => 'get_parity',
  writer    => 'set_parity',
  # private methods
  trigger   => \&_trigger_parity,
);

has 'stopbits' => (
  isa       => 'sp_stopbits',
  reader    => 'get_stopbits',
  writer    => 'set_stopbits',
  # private methods
  trigger   => \&_trigger_stopbits,
);

has 'rts' => (
  isa       => 'sp_rts',
  reader    => 'get_rts',
  writer    => 'set_rts',
  # private methods
  trigger   => \&_trigger_rts,
);

has 'cts' => (
  isa       => 'sp_cts',
  reader    => 'get_cts',
  writer    => 'set_cts',
  # private methods
  trigger   => \&_trigger_cts,
);

has 'dtr' => (
  isa       => 'sp_dtr',
  reader    => 'get_dtr',
  writer    => 'set_dtr',
  # private methods
  trigger   => \&_trigger_dtr,
);

has 'dsr' => (
  isa       => 'sp_dsr',
  reader    => 'get_dsr',
  writer    => 'set_dsr',
  # private methods
  trigger   => \&_trigger_dsr,
);

has 'xon_xoff' => (
  isa       => 'sp_xonxoff',
  reader    => 'get_xon_xoff',
  writer    => 'set_xon_xoff',
  # private methods
  trigger   => \&_trigger_xon_xoff,
);

has 'flowcontrol' => (
  isa       => 'sp_flowcontrol',
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
  my $attr = $self->_get_config_baudrate;
  $self->{baudrate} = $attr if defined $attr;
  return $self->$next;
};

around 'get_bits' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_bits;
  $self->{bits} = $attr if defined $attr;
  return $self->$next;
};

around 'get_parity' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_parity;
  $self->{parity} = $attr if defined $attr;
  return $self->$next;
};

around 'get_stopbits' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_stopbits;
  $self->{stopbits} = $attr if defined $attr;
  return $self->$next;
};

around 'get_rts' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_rts;
  $self->{rts} = $attr if defined $attr;
  return $self->$next;
};

around 'get_cts' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_cts;
  $self->{cts} = $attr if defined $attr;
  return $self->$next;
};

around 'get_dtr' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_dtr;
  $self->{dtr} = $attr if defined $attr;
  return $self->$next;
};

around 'get_dsr' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_dsr;
  $self->{dsr} = $attr if defined $attr;
  return $self->$next;
};

around 'get_xon_xoff' => sub {
  my ($next, $self) = @_;
  my $attr = $self->_get_config_xon_xoff;
  $self->{xon_xoff} = $attr if defined $attr;
  return $self->$next;
};

##
#
# extends default methods
#
##

sub DEMOLISH {
  my $self = shift;
  $self->_free_config if $self->_has_handle
}

##
#
# additional public methods
#
##

sub cget
{
  my ($self, $param) = @_;
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
      $self->SET_ERROR(SP_ERR_ARG, 'Invalid Argument');
      return undef;
    }
  }
  return $self->is_ok ? $ret_val : undef;
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
  $self->RETURN_OK;
  $self->set_baudrate     ( $options{'-baudrate'}     ) if $options{'-baudrate'};
    return undef unless $self->is_ok;
  $self->set_bits         ( $options{'-bits'}         ) if $options{'-bits'};
    return undef unless $self->is_ok;
  $self->set_parity       ( $options{'-parity'}       ) if $options{'-parity'};
    return undef unless $self->is_ok;
  $self->set_stopbits     ( $options{'-stopbits'}     ) if $options{'-stopbits'};
    return undef unless $self->is_ok;
  $self->set_rts          ( $options{'-rts'}          ) if $options{'-rts'};
    return undef unless $self->is_ok;
  $self->set_rts          ( $options{'-cts'}          ) if $options{'-cts'};
    return undef unless $self->is_ok;
  $self->set_rts          ( $options{'-dtr'}          ) if $options{'-dtr'};
    return undef unless $self->is_ok;
  $self->set_rts          ( $options{'-dsr'}          ) if $options{'-dsr'};
    return undef unless $self->is_ok;
  $self->set_xon_xoff     ( $options{'-xon_xoff'}     ) if $options{'-xon_xoff'};
    return undef unless $self->is_ok;
  $self->set_flowcontrol  ( $options{'-flowcontrol'}  ) if $options{'-flowcontrol'};
    return undef unless $self->is_ok;
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
  my $handle;
  $self->_set_return_code(sp_new_config(\$handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  unless ($handle) {
    $self->SET_FAIL('Undefined result');
    return undef;
  }
  return $handle;
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
  $self->_set_return_code(sp_set_config_baudrate($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_bits
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_databits' },
    { isa => 'sp_databits', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_bits($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_parity
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_parity' },
    { isa => 'sp_parity', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_parity($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_stopbits
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_stopbits' },
    { isa => 'sp_stopbits', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_stopbits($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_rts
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_rts' },
    { isa => 'sp_rts', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_rts($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_cts
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_cts' },
    { isa => 'sp_cts', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_cts($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_dtr
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dtr' },
    { isa => 'sp_dtr', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_dtr($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_dsr
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dsr' },
    { isa => 'sp_dsr', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_dsr($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_xon_xoff
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_xonxoff' },
    { isa => 'sp_xonxoff', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_xon_xoff($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _trigger_flowcontrol
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_flowcontrol' },
    { isa => 'sp_flowcontrol', optional => 1 },
  );
  $self->_set_return_code(sp_set_config_flowcontrol($self->get_handle, $new));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

##
#
# private backend wrapper methods
#
##

sub _get_config_baudrate {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_baudrate($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_bits {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_bits($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_parity {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_parity($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_stopbits {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_stopbits($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_rts {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_rts($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_cts {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_cts($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dtr {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_dtr($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dsr {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_dsr($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _get_config_xon_xoff {
  my $self = shift;
  my $ret_val;
  $self->_set_return_code(sp_get_config_xon_xoff($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
};

sub _free_config
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined config');
    return;
  }
  sp_free_config($self->get_handle);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
