#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include <libserialport.h>

#ifndef SP_ADDRLEN 
#  define SP_ADDRLEN 2*sizeof(IV)
#endif

/* SvPVCLEAR only from perl 5.25.6 */
#ifndef SvPVCLEAR
#  define SvPVCLEAR(sv) sv_setpvs((sv), "")
#endif

#ifdef _WIN32
#include <windows.h>
  typedef HANDLE  SP_PORT_HANDLE;
#else
  typedef int     SP_PORT_HANDLE;
#endif

#if SP_PACKAGE_VERSION_MAJOR > 0
# define SP_PACKAGE_VERSION_GE_0_1_1
#else
# if SP_PACKAGE_VERSION_MINOR > 1
#   define SP_PACKAGE_VERSION_GE_0_1_1
# else
#   if SP_PACKAGE_VERSION_MICRO >= 1
#     define SP_PACKAGE_VERSION_GE_0_1_1
#   endif
# endif
#endif

void debug_handler(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  fprintf(stderr, "sp: ");
  vfprintf(stderr, fmt, args);
  va_end(args);
}

/**
 *
 * Sigrok::SerialPort
 * 
 **/

MODULE = Sigrok__SerialPort   PACKAGE = Sigrok::SerialPort

PROTOTYPES: ENABLE

 ##
 #
 # Register constants
 #
 ##

BOOT:
{
  HV *stash;
  stash = gv_stashpvn("Sigrok::SerialPort", strlen("Sigrok::SerialPort"), TRUE);

  newCONSTSUB( stash, "_loaded", newSViv(1) );

  /* Return values */
  newCONSTSUB( stash, "SP_OK",        newSViv( SP_OK ) );
  newCONSTSUB( stash, "SP_ERR_ARG",   newSViv( SP_ERR_ARG ) );
  newCONSTSUB( stash, "SP_ERR_FAIL",  newSViv( SP_ERR_FAIL ) );
  newCONSTSUB( stash, "SP_ERR_MEM",   newSViv( SP_ERR_MEM ) );
  newCONSTSUB( stash, "SP_ERR_SUPP",  newSViv( SP_ERR_SUPP ) );

  /* Port access modes */
  newCONSTSUB( stash, "SP_MODE_READ",       newSViv( SP_MODE_READ ) );
  newCONSTSUB( stash, "SP_MODE_WRITE",      newSViv( SP_MODE_WRITE ) );
#ifdef SP_PACKAGE_VERSION_GE_0_1_1
  newCONSTSUB( stash, "SP_MODE_READ_WRITE", newSViv( SP_MODE_READ_WRITE ) );
#endif

  /* Port events */
  newCONSTSUB( stash, "SP_EVENT_RX_READY",  newSViv( SP_EVENT_RX_READY ) );
  newCONSTSUB( stash, "SP_EVENT_TX_READY",  newSViv( SP_EVENT_TX_READY ) );
  newCONSTSUB( stash, "SP_EVENT_ERROR",     newSViv( SP_EVENT_ERROR ) );

  /* Buffer selection */
  newCONSTSUB( stash, "SP_BUF_INPUT",   newSViv( SP_BUF_INPUT ) );
  newCONSTSUB( stash, "SP_BUF_OUTPUT",  newSViv( SP_BUF_OUTPUT ) );
  newCONSTSUB( stash, "SP_BUF_BOTH",    newSViv( SP_BUF_BOTH ) );

  /* Parity settings */
  newCONSTSUB( stash, "SP_PARITY_INVALID",  newSViv( SP_PARITY_INVALID ) );
  newCONSTSUB( stash, "SP_PARITY_NONE",     newSViv( SP_PARITY_NONE ) );
  newCONSTSUB( stash, "SP_PARITY_ODD",      newSViv( SP_PARITY_ODD ) );
  newCONSTSUB( stash, "SP_PARITY_EVEN",     newSViv( SP_PARITY_EVEN ) );
  newCONSTSUB( stash, "SP_PARITY_MARK",     newSViv( SP_PARITY_MARK ) );
  newCONSTSUB( stash, "SP_PARITY_SPACE",    newSViv( SP_PARITY_SPACE ) );

  /* RTS pin behaviour */
  newCONSTSUB( stash, "SP_RTS_INVALID",       newSViv( SP_RTS_INVALID ) );
  newCONSTSUB( stash, "SP_RTS_OFF",           newSViv( SP_RTS_OFF ) );
  newCONSTSUB( stash, "SP_RTS_ON",            newSViv( SP_RTS_ON ) );
  newCONSTSUB( stash, "SP_RTS_FLOW_CONTROL",  newSViv( SP_RTS_FLOW_CONTROL ) );

  /* CTS pin behaviour */
  newCONSTSUB( stash, "SP_CTS_INVALID",       newSViv( SP_CTS_INVALID ) );
  newCONSTSUB( stash, "SP_CTS_IGNORE",        newSViv( SP_CTS_IGNORE ) );
  newCONSTSUB( stash, "SP_CTS_FLOW_CONTROL",  newSViv( SP_CTS_FLOW_CONTROL ) );

  /* DTR pin behaviour */
  newCONSTSUB( stash, "SP_DTR_INVALID",       newSViv( SP_DTR_INVALID ) );
  newCONSTSUB( stash, "SP_DTR_OFF",           newSViv( SP_DTR_OFF ) );
  newCONSTSUB( stash, "SP_DTR_ON",            newSViv( SP_DTR_ON ) );
  newCONSTSUB( stash, "SP_DTR_FLOW_CONTROL",  newSViv( SP_DTR_FLOW_CONTROL ) );

  /* DSR pin behaviour */
  newCONSTSUB( stash, "SP_DSR_INVALID",       newSViv( SP_DSR_INVALID ) );
  newCONSTSUB( stash, "SP_DSR_IGNORE",        newSViv( SP_DSR_IGNORE ) );
  newCONSTSUB( stash, "SP_DSR_FLOW_CONTROL",  newSViv( SP_DSR_FLOW_CONTROL ) );

  /* XON/XOFF flow control behaviour */
  newCONSTSUB( stash, "SP_XONXOFF_INVALID",   newSViv( SP_XONXOFF_INVALID ) );
  newCONSTSUB( stash, "SP_XONXOFF_DISABLED",  newSViv( SP_XONXOFF_DISABLED ) );
  newCONSTSUB( stash, "SP_XONXOFF_IN",        newSViv( SP_XONXOFF_IN ) );
  newCONSTSUB( stash, "SP_XONXOFF_OUT",       newSViv( SP_XONXOFF_OUT ) );
  newCONSTSUB( stash, "SP_XONXOFF_INOUT",     newSViv( SP_XONXOFF_INOUT ) );

  /* tandard flow control combinations */
  newCONSTSUB( stash, "SP_FLOWCONTROL_NONE",    newSViv( SP_FLOWCONTROL_NONE ) );
  newCONSTSUB( stash, "SP_FLOWCONTROL_XONXOFF", newSViv( SP_FLOWCONTROL_XONXOFF ) );
  newCONSTSUB( stash, "SP_FLOWCONTROL_RTSCTS",  newSViv( SP_FLOWCONTROL_RTSCTS ) );
  newCONSTSUB( stash, "SP_FLOWCONTROL_DTRDSR",  newSViv( SP_FLOWCONTROL_DTRDSR ) );

  /* Input signals */
  newCONSTSUB( stash, "SP_SIG_CTS", newSViv( SP_SIG_CTS ) );
  newCONSTSUB( stash, "SP_SIG_DSR", newSViv( SP_SIG_DSR ) );
  newCONSTSUB( stash, "SP_SIG_DCD", newSViv( SP_SIG_DCD ) );
  newCONSTSUB( stash, "SP_SIG_RI",  newSViv( SP_SIG_RI ) );
 
  /* Transport types */
#ifdef SP_PACKAGE_VERSION_GE_0_1_1
  newCONSTSUB( stash, "SP_TRANSPORT_NATIVE",    newSViv( SP_TRANSPORT_NATIVE ) );
  newCONSTSUB( stash, "SP_TRANSPORT_USB",       newSViv( SP_TRANSPORT_USB ) );
  newCONSTSUB( stash, "SP_TRANSPORT_BLUETOOTH", newSViv( SP_TRANSPORT_BLUETOOTH ) );
#endif

  /* Package version macros */
  newCONSTSUB( stash, "SP_PACKAGE_VERSION_MAJOR",   newSViv( SP_PACKAGE_VERSION_MAJOR ) );
  newCONSTSUB( stash, "SP_PACKAGE_VERSION_MINOR",   newSViv( SP_PACKAGE_VERSION_MINOR ) );
  newCONSTSUB( stash, "SP_PACKAGE_VERSION_MICRO",   newSViv( SP_PACKAGE_VERSION_MICRO ) );
  newCONSTSUB( stash, "SP_PACKAGE_VERSION_STRING",  newSVpv( SP_PACKAGE_VERSION_STRING, strlen(SP_PACKAGE_VERSION_STRING) ) );

  /* Library/libtool version macros */
  newCONSTSUB( stash, "SP_LIB_VERSION_CURRENT",   newSViv( SP_LIB_VERSION_CURRENT ) );
  newCONSTSUB( stash, "SP_LIB_VERSION_REVISION",  newSViv( SP_LIB_VERSION_REVISION ) );
  newCONSTSUB( stash, "SP_LIB_VERSION_AGE",       newSViv( SP_LIB_VERSION_AGE ) );
  newCONSTSUB( stash, "SP_LIB_VERSION_STRING",    newSVpv( SP_LIB_VERSION_STRING, strlen(SP_LIB_VERSION_STRING) ) );
}

 ##
 #
 # Port enumeration
 #
 ##

enum sp_return
sp_get_port_by_name(portname, port_ptr)
    const char* portname;
    struct sp_port** port_ptr;
  PREINIT:
    struct sp_port* port = NULL;
  CODE:
  {
    RETVAL = sp_get_port_by_name(portname, &port);
    if (RETVAL == SP_OK) {
      sv_setiv((SV*)port_ptr, PTR2IV(port));
      SvSETMAGIC((SV*)port_ptr);
    }
  }
  OUTPUT:
    RETVAL

void
sp_free_port(port)
    SV* port;
  INIT:
    SvGETMAGIC(port);
  CODE:
  {
    if (SvIOK(port)) {
      sp_free_port(INT2PTR(struct sp_port*, SvIV(port)));
      sv_setsv(port, &PL_sv_undef);
      SvSETMAGIC(port);
    } else {
      warn("Sigrok::SerialPort::sp_free_port: port is not of valid SCALAR");
    }
  }

enum sp_return
sp_list_ports(list_ptr);
    struct sp_port*** list_ptr;
  PREINIT:
    struct sp_port** ports = NULL;
    struct sp_port* port = NULL;
    int i;
  CODE:
  {
    RETVAL = sp_list_ports(&ports);
    if (RETVAL == SP_OK) {
      av_clear((AV*)list_ptr);
      if (ports) {
        /* store each 'sp_port' to the given ARRAY reference 'list_ptr' */
        for (i = 0; ports[i]; i++) {
          RETVAL = sp_copy_port(ports[i], &port);
          if (RETVAL != SP_OK)
            break;
          av_push( (AV*)list_ptr, newSViv(PTR2IV(port)) );
        }
        sp_free_port_list(ports);
      }
      SvSETMAGIC((SV*)list_ptr);
    }
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_copy_port(port, copy_ptr)
    const struct sp_port* port;
    struct sp_port** copy_ptr;
  PREINIT:
    struct sp_port* copy = NULL;
  CODE:
  {
    RETVAL = sp_copy_port(port, &copy);
    if (RETVAL == SP_OK) {
      sv_setiv((SV*)copy_ptr, PTR2IV(copy));
      SvSETMAGIC((SV*)copy_ptr);
    }
  }
  OUTPUT:
    RETVAL

void
sp_free_port_list( ... )
  PREINIT:
    SV* sv_port;
    U32 ix_ports = 0;
  INIT:
    if (items < 1)
      croak("Usage: Sigrok::SerialPort::sp_free_port_list(ports)");
  CODE:
  {
    while (items--) {
      sv_port = ST(ix_ports++);
      SvGETMAGIC(sv_port);
      if (SvIOK(sv_port) && SvIVX(sv_port) > 0) {
        sp_free_port( INT2PTR(struct sp_port* , SvIV(sv_port)) );
        sv_setiv(sv_port, 0);
        SvSETMAGIC(sv_port);
      } else {
        warn("Sigrok::SerialPort::sp_free_port_list: ports has an invalid ARRAY entry");
      }
    }
  }

 ##
 #
 # Port handling
 #
 ##

enum sp_return
sp_open(port, flags);
    struct sp_port* port;
    enum sp_mode flags;

enum sp_return
sp_close(port);
    struct sp_port* port;

char*
sp_get_port_name(port);
    const struct sp_port* port;

#ifdef SP_PACKAGE_VERSION_GE_0_1_1

char*
sp_get_port_description(port);
    const struct sp_port* port;

enum sp_transport
sp_get_port_transport(port);
    const struct sp_port* port;

enum sp_return
sp_get_port_usb_bus_address(port, usb_bus, usb_address);
    const struct sp_port* port;
    int* usb_bus;
    int* usb_address;
  PREINIT:
    int bus;
    int address;
  CODE:
  {
    RETVAL = sp_get_port_usb_bus_address(port, &bus, &address);
    if (RETVAL == SP_OK)
    {
      sv_setiv((SV*)usb_bus, (IV)bus);
      SvSETMAGIC((SV*)usb_bus);
      sv_setiv((SV*)usb_address, (IV)address);
      SvSETMAGIC((SV*)usb_address);
    }
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_get_port_usb_vid_pid(port, usb_vid, usb_pid);
    const struct sp_port* port;
    int* usb_vid;
    int* usb_pid;
  PREINIT:
    int vid;
    int pid;
  CODE:
  {
    RETVAL = sp_get_port_usb_vid_pid(port, &vid, &pid);
    if (RETVAL == SP_OK)
    {
      sv_setiv((SV*)usb_vid, (IV)vid);
      SvSETMAGIC((SV*)usb_vid);
      sv_setiv((SV*)usb_pid, (IV)pid);
      SvSETMAGIC((SV*)usb_pid);
    }
  }
  OUTPUT:
    RETVAL

char*
sp_get_port_usb_manufacturer(port);
    const struct sp_port* port;

char*
sp_get_port_usb_product(port);
    const struct sp_port* port;

char*
sp_get_port_usb_serial(port);
    const struct sp_port* port;

char*
sp_get_port_bluetooth_address(port);
    const struct sp_port* port;

#endif

enum sp_return
sp_get_port_handle(port, result_ptr);
    const struct sp_port* port;
    SP_PORT_HANDLE* result_ptr;
  PREINIT:
    SP_PORT_HANDLE result;
  CODE:
  {
    RETVAL = sp_get_port_handle(port, &result);
    if (RETVAL == SP_OK) {
      sv_setiv((SV*)result_ptr, (IV)result);
      SvSETMAGIC((SV*)result_ptr);
    }
  }
  OUTPUT:
    RETVAL

 ##
 #
 # Configuration
 #
 ##

enum sp_return
sp_new_config(config_ptr);
    struct sp_port_config** config_ptr
  PREINIT:
    struct sp_port_config* config = NULL;
  CODE:
  {
    RETVAL = sp_new_config(&config);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)config_ptr, PTR2IV(config));
  }
  OUTPUT:
    RETVAL

void
sp_free_config(config)
    SV* config;
  INIT:
    SvGETMAGIC(config);
  CODE:
  {
    if (SvIOK(config)) {
      sp_free_config(INT2PTR(struct sp_port_config*, SvIV(config)));
      sv_setsv(config, &PL_sv_undef);
      SvSETMAGIC((SV*)config);
    } else {
      warn("Sigrok::SerialPort::sp_free_config: config is not of valid SCALAR");
    }
  }

enum sp_return
sp_get_config(port, config);
    struct sp_port* port;
    struct sp_port_config* config;

enum sp_return
sp_set_config(port, config);
    struct sp_port* port;
    const struct sp_port_config* config;

enum sp_return
sp_set_baudrate(port, baudrate);
    struct sp_port* port;
    int baudrate;

enum sp_return
sp_get_config_baudrate(config, baudrate_ptr);
    const struct sp_port_config* config;
    int* baudrate_ptr;
  PREINIT:
    int baudrate = 0;
  CODE:
  {
    RETVAL = sp_get_config_baudrate(config, &baudrate);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)baudrate_ptr, (IV)baudrate);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_baudrate(config, baudrate);
    struct sp_port_config* config;
    int baudrate;

enum sp_return
sp_set_bits(port, bits);
    struct sp_port* port;
    int bits;

enum sp_return
sp_get_config_bits(config, bits_ptr);
  const struct sp_port_config* config;
    int* bits_ptr;
  PREINIT:
    int bits = 0;
  CODE:
  {
    RETVAL = sp_get_config_bits(config, &bits);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)bits_ptr, (IV)bits);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_bits(config, bits);
    struct sp_port_config* config;
    int bits;

enum sp_return
sp_set_parity(port, parity);
    struct sp_port* port;
    enum sp_parity parity;

enum sp_return
sp_get_config_parity(config, parity_ptr);
    struct sp_port_config* config;
    enum sp_parity *parity_ptr;
  PREINIT:
    enum sp_parity parity = SP_PARITY_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_parity(config, &parity);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)parity_ptr, (IV)parity);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_parity(config, parity);
    struct sp_port_config* config;
    enum sp_parity parity;

enum sp_return
sp_set_stopbits(port, stopbits);
    struct sp_port* port;
    int stopbits;

enum sp_return
sp_get_config_stopbits(config, stopbits_ptr);
    const struct sp_port_config* config;
    int* stopbits_ptr;
  PREINIT:
    int stopbits = 0;
  CODE:
  {
    RETVAL = sp_get_config_stopbits(config, &stopbits);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)stopbits_ptr, (IV)stopbits);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_stopbits(config, stopbits);
    struct sp_port_config* config;
    int stopbits;

enum sp_return
sp_set_rts(port, rts);
    struct sp_port* port;
    enum sp_rts rts;

enum sp_return
sp_get_config_rts(config, rts_ptr);
    struct sp_port_config* config;
    enum sp_rts* rts_ptr;
  PREINIT:
    enum sp_rts rts = SP_RTS_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_rts(config, &rts);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)rts_ptr, (IV)rts);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_rts(config, rts);
    struct sp_port_config* config;
    enum sp_rts rts;

enum sp_return
sp_set_cts(port, cts);
    struct sp_port* port;
    enum sp_cts cts;

enum sp_return
sp_get_config_cts(config, cts_ptr);
    struct sp_port_config* config;
    enum sp_cts* cts_ptr;
  PREINIT:
    enum sp_cts cts = SP_CTS_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_cts(config, &cts);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)cts_ptr, (IV)cts);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_cts(config, cts);
    struct sp_port_config* config;
    enum sp_cts cts;

enum sp_return
sp_set_dtr(port, dtr);
    struct sp_port* port;
    enum sp_dtr dtr;

enum sp_return
sp_get_config_dtr(config, dtr_ptr);
    struct sp_port_config* config;
    enum sp_dtr* dtr_ptr;
  PREINIT:
    enum sp_dtr dtr = SP_DTR_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_dtr(config, &dtr);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)dtr_ptr, (IV)dtr);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_dtr(config, dtr);
    struct sp_port_config* config;
    enum sp_dtr dtr;

enum sp_return
sp_set_dsr(port, dsr);
    struct sp_port* port;
    enum sp_dsr dsr;

enum sp_return
sp_get_config_dsr(config, dsr_ptr);
    struct sp_port_config* config;
    enum sp_dsr* dsr_ptr;
  PREINIT:
    enum sp_dsr dsr = SP_DSR_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_dsr(config, &dsr);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)dsr_ptr, (IV)dsr);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_dsr(config, dsr);
    struct sp_port_config* config;
    enum sp_dsr dsr;

enum sp_return
sp_set_xon_xoff(port, xon_xoff);
    struct sp_port* port;
    enum sp_xonxoff xon_xoff;

enum sp_return
sp_get_config_xon_xoff(config, xon_xoff_ptr);
    struct sp_port_config* config;
    enum sp_xonxoff* xon_xoff_ptr;
  PREINIT:
    enum sp_xonxoff xon_xoff = SP_RTS_INVALID;
  CODE:
  {
    RETVAL = sp_get_config_xon_xoff(config, &xon_xoff);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)xon_xoff_ptr, (IV)xon_xoff);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_set_config_xon_xoff(config, xon_xoff);
    struct sp_port_config* config;
    enum sp_xonxoff xon_xoff;

enum sp_return
sp_set_flowcontrol(port, flowcontrol);
    struct sp_port* port;
    enum sp_flowcontrol flowcontrol;

enum sp_return
sp_set_config_flowcontrol(config, flowcontrol);
    struct sp_port_config* config;
    enum sp_flowcontrol flowcontrol;

 ##
 #
 # Data handling
 #
 ##

int
sp_blocking_read(port, buf, count, timeout_ms);
    struct sp_port* port;
    SV* buf;
    size_t count;
    unsigned int timeout_ms;
  PREINIT:
    STRLEN xpv_length;
    char* xpv_pv;
  INIT:
    SvGETMAGIC(buf);
    if (!SvROK(buf))
      croak("Sigrok::SerialPort::sp_blocking_read_next: buf is not a reference");
    buf = SvRV(buf);
    if (!SvPOK(buf))
      croak("Sigrok::SerialPort::sp_blocking_read: buf is not a valid string reference");
  CODE:
  {
    /* We don't need the existing content of the buffer string */
    SvPVCLEAR(buf);
    /* Generate a warning if the memory size (xpv_length) of the buffer is smaller than needed */
    xpv_length = SvLEN(buf);
    if (count >= xpv_length)
      warn("Sigrok::SerialPort::sp_blocking_read: the size of buf is smaller than count.");
    /* SvGROW will automatically grow the buffer string for us */
    /* we add space for a trailing NUL like perl's own string functions */
    xpv_pv = SvGROW(buf, count + 1);
    xpv_pv[count] = '\0';
    /* call the native c routine */
    count = sp_blocking_read(port, xpv_pv, count, timeout_ms);
    /* SvCUR_set set the current length of the buffer string */
    if (count > 0)
      SvCUR_set(buf, count);
    /* SvPOK_only turns off the IOK and NOK flags and turns on POK */
    /* SvPOK_only also clears SVf_UTF8 */
    SvPOK_only((SV*)buf);
    SvSETMAGIC((SV*)buf);
    RETVAL = count;
  }
  OUTPUT:
    RETVAL

#ifdef SP_PACKAGE_VERSION_GE_0_1_1

int
sp_blocking_read_next(port, buf, count, timeout_ms);
    struct sp_port* port;
    SV* buf;
    size_t count;
    unsigned int timeout_ms;
  PREINIT:
    STRLEN xpv_length;
    char* xpv_pv;
  INIT:
    SvGETMAGIC(buf);
    if (!SvROK(buf))
      croak("Sigrok::SerialPort::sp_blocking_read_next: buf is not a reference");
    buf = SvRV(buf);
    if (!SvPOK(buf))
      croak("Sigrok::SerialPort::sp_blocking_read_next: buf is not a valid string reference");
  CODE:
  {
    SvPVCLEAR(buf);
    xpv_length = SvLEN(buf);
    if (count >= xpv_length)
      warn("Sigrok::SerialPort::sp_blocking_read_next: the size of buf is smaller than count.");
    xpv_pv = SvGROW(buf, count + 1);
    xpv_pv[count] = '\0';
    count = sp_blocking_read_next(port, xpv_pv, count, timeout_ms);
    if (count > 0)
      SvCUR_set(buf, count);
    SvPOK_only(buf);
    SvSETMAGIC(buf);
    RETVAL = count;
  }
  OUTPUT:
    RETVAL

#endif

int
sp_nonblocking_read(port, buf, count);
    struct sp_port* port;
    SV* buf;
    size_t count;
  PREINIT:
    STRLEN xpv_length;
    char* xpv_pv;
  INIT:
    SvGETMAGIC(buf);
    if (!SvROK(buf))
      croak("Sigrok::SerialPort::sp_nonblocking_read: buf is not a reference");
    buf = SvRV(buf);
    if (!SvPOK(buf))
      croak("Sigrok::SerialPort::sp_nonblocking_read: buf is not a valid string reference");
  CODE:
  {
    SvPVCLEAR(buf);
    xpv_length = SvLEN(buf);
    if (count >= xpv_length)
      warn("Sigrok::SerialPort::sp_nonblocking_read: the size of buf is smaller than count.");
    xpv_pv = SvGROW(buf, count + 1);
    xpv_pv[count] = '\0';
    count = sp_nonblocking_read(port, xpv_pv, count);
    if (count > 0)
      SvCUR_set(buf, count);
    SvPOK_only(buf);
    SvSETMAGIC(buf);
    RETVAL = count;
  }
  OUTPUT:
    RETVAL

int
sp_blocking_write(port, buf, count, timeout_ms);
    struct sp_port* port;
    SV* buf;
    size_t count;
    unsigned int timeout_ms;
  PREINIT:
    STRLEN xpv_cur;
    char* xpv_pv;
  INIT:
    if (!SvPOK(buf))
      croak("Sigrok::SerialPort::sp_blocking_write: buf is not a valid (packed) string");
    xpv_cur = SvCUR(buf);
    xpv_pv = SvPV_nolen(buf);
    if (count > xpv_cur) {
      warn("Sigrok::SerialPort::sp_blocking_write: the amount of buf is smaller than count.");
      count = xpv_cur;
    }
  CODE:
  {
    RETVAL = sp_blocking_write(port, xpv_pv, count, timeout_ms);
  }
  OUTPUT:
    RETVAL

int
sp_nonblocking_write(port, buf, count);
    struct sp_port* port;
    SV* buf;
    size_t count;
  PREINIT:
    STRLEN xpv_cur;
    char* xpv_pv;
  INIT:
    if (!SvPOK(buf))
      croak("Sigrok::SerialPort::sp_nonblocking_write: buf is not a valid (packed) string");
    xpv_cur = SvCUR(buf);
    if (count > xpv_cur) {
      warn("Sigrok::SerialPort::sp_nonblocking_write: the amount of buf is smaller than count.");
      count = xpv_cur;
    }
    xpv_pv = SvPV_nolen(buf);
  CODE:
  {
    RETVAL = sp_nonblocking_write(port, xpv_pv, count);
  }
  OUTPUT:
    RETVAL

int
sp_input_waiting(port);
  struct sp_port *port;

int
sp_output_waiting(port);
  struct sp_port *port;

enum sp_return
sp_flush(port, buffers);
  struct sp_port *port;
  enum sp_buffer buffers;

enum sp_return
sp_drain(port);
  struct sp_port *port;

 ##
 #
 # Waiting
 #
 ##
 
enum sp_return
sp_new_event_set(result_ptr);
    struct sp_event_set** result_ptr
  PREINIT:
    struct sp_event_set* event_set = NULL;
  CODE:
  {
    RETVAL = sp_new_event_set(&event_set);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)result_ptr, PTR2IV(event_set));
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_add_port_events(event_set, port, mask);
    struct sp_event_set* event_set;
    const struct sp_port* port;
    enum sp_event mask;

enum sp_return
sp_wait(event_set, timeout_ms);
    struct sp_event_set* event_set;
    unsigned int timeout_ms;

void
sp_free_event_set(event_set)
    SV* event_set;
  INIT:
    SvGETMAGIC(event_set);
  CODE:
  {
    if (SvIOK(event_set)) {
      sp_free_event_set(INT2PTR(struct sp_event_set*, SvIV(event_set)));
      sv_setsv(event_set, &PL_sv_undef);
      SvSETMAGIC(event_set);
    } else {
      warn("Sigrok::SerialPort::sp_free_event_set: event_set is not a valid SCALAR");
    }
  }

 ##
 #
 # Signals
 #
 ##
 
enum sp_return
sp_get_signals(port, signal_mask);
    struct sp_port* port;
    enum sp_signal* signal_mask;
  PREINIT:
    enum sp_signal mask = 0;
  CODE:
  {
    RETVAL = sp_get_signals(port, &mask);
    if (RETVAL == SP_OK)
      sv_setiv((SV*)signal_mask, (IV)mask);
  }
  OUTPUT:
    RETVAL

enum sp_return
sp_start_break(port);
    struct sp_port* port;

enum sp_return
sp_end_break(port);
    struct sp_port* port;

 ##
 #
 # Errors
 #
 ##

int
sp_last_error_code();

SV*
sp_last_error_message();
  PREINIT:
    char* message;
  CODE:
  {
    message = sp_last_error_message();
    if (message) {
      RETVAL = newSVpv(message, strlen(message));
      sp_free_error_message(message);
    }
  }
  OUTPUT:
    RETVAL

void
sp_free_error_message(message);
    SV* message;
  INIT:
    SvGETMAGIC(message);
  CODE:
  {
    if (SvPOK(message)) {
      SvPVCLEAR(message);
      sv_setsv(message, &PL_sv_undef);
      SvSETMAGIC(message);
    } else {
      warn("Sigrok::SerialPort::sp_free_error_message: message is not a string");
    }
  }

void
sp_set_debug(enable)
  int enable;
  CODE:
  {
    sp_set_debug_handler(enable ? debug_handler : NULL);
  }

 ##
 #
 # Versions
 #
 ##
 
int
sp_get_major_package_version();

int
sp_get_minor_package_version();

int
sp_get_micro_package_version();

const char*
sp_get_package_version_string();

int
sp_get_current_lib_version();

int
sp_get_revision_lib_version();

int
sp_get_age_lib_version();

const char*
sp_get_lib_version_string();
