##############################################
# $Id: 99_myUtils.pm  $
package main;

use strict;
use warnings;
use POSIX;

sub
myUtils_Initialize($$)
{
  my ($hash) = @_;
}

sub undefined($$)
{
  my ($object, $value) = @_;
  fhem("set $object $value") if(ReadingsVal("$object","state","undef") eq "undef")
}

sub lightswitch_MAX($$)
{
  my ($event, $light) = @_;

  if ("$event" eq "off") {
    {fhem("set $light off")}
  }
  else {
    if ("$event" eq "on") {
      if (ReadingsVal("$light","brightness",0) > 0) {
        {fhem("set $light preset +")}
      } else {
        {fhem("set $light on")}
      }
    }
  }
}

sub lightswitch_HE($$)
{
  my ($event, $light) = @_;
  lightswitch_MAX($event, $light);
}

sub night_milight($$)
{
  my ($event, $light) = @_;

  # Save current state of light
  my $state = "off";
  if (ReadingsVal("$light","brightness",0) > 0) {
    $state = "on";
  }

  # Set to night or day colours
  if ("$event" eq "on") {
    {fhem("set $light preset 1")}
  }
  else {
    if ("$event" eq "off") {
      {fhem("set $light preset 0")}
    }
  }

  # Restore state of light
  {fhem("set $light $state 0")}    
}


######## Valve position heating control  ############
sub
valve_pos($)
{
#Log 3, "Valve position dependent heating control...";
my $threshold_val = $_[0];
my $valve = 0;
my @pos = ();
my $total = 0;
my @MAX_HT=devspec2array("DEF=HeatingThermostat.*");
 foreach(@MAX_HT) {
  $valve=ReadingsVal($_, "valveposition", "0");
  push(@pos,$valve);
  $total=$total+$valve;
 }
 if (($total > $threshold_val) && (ReadingsVal("house.heating.request","state","off") eq "off")) {
  fhem "set house.heating.request on";
  Log 3, "Heating ON: @pos, Total: $total, Threshold: $threshold_val"
 } elsif (($total < $threshold_val) && (ReadingsVal("house.heating.request","state","off") eq "on")) {
  fhem "set house.heating.request off";
  Log 3, "Heating OFF: @pos, Total: $total, Threshold: $threshold_val"
  } else {
  Log 4, "Heating UNCHANGED: @pos, Total: $total, Threshold: $threshold_val"
 }
 fhem ("set house.heating.auto.valve.sum $total");
}

##### Work in progress / Archive #####
sub lounge_tv_off()
{
  {fhem ("set lounge.tv POWEROFF")}
  {fhem ("set lounge.squeezebox off")}
  sleep 5;
  {fhem ("set lounge.pdu off 1")}
  {fhem ("set lounge.pdu off 2")}
}

sub lounge_tv_audio()
{
  if (Value("lounge.pdu:2_socket_2") eq "off")
    {fhem ("set lounge.pdu on 2")}
  if (Value("lounge.pdu:1_socket_1") eq "off") {
    {fhem ("set lounge.pdu on 1")}
    sleep 0.5
  }
  {fhem("set lounge.tv DTV")}
  {fhem("set lounge.tv HDMI")}
  {fhem("set lounge.tv HDMI")}
}

sub battery_low($$)
{
  my ($event, $lowbatt) = @_;
  (my $num) = $event =~ /(\d+)/;
  if (looks_like_number($num)) {
    if ($num < 20) {
      fhem("set $lowbatt low");
    }
  } else {
    if ($event =~ m/low/) {
      fhem("set $lowbatt low");
    }
  }
}

1;
