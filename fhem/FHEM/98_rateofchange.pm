# $Id$
##############################################
#
# Rate of Change computing 
#
# based on 98_THRESHOLD.pm and other modules (C) by Matthew Wire
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# The GNU General Public License may also be found at http://www.gnu.org/licenses/gpl-2.0.html .

package main;
use strict;
use warnings;

##########################
sub
rateofchange_Initialize($)
{
  my ($hash) = @_;
  $hash->{DefFn}   = "rateofchange_Define";
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
  $hash->{NotifyFn} = "rateofchange_Notify";
>>>>>>> 2057217a4... Add new module rateofchange
=======
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
  $hash->{NotifyFn} = "rateofchange_Notify";
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
  $hash->{NotifyFn} = "rateofchange_Notify";
>>>>>>> 4166c18b3... Add new module rateofchange
=======
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
  $hash->{NotifyOrderPrefix} = "10-";   # Want to be called before the rest
  $hash->{AttrList} = "disable:0,1 " .
                      "maxRuntime " .
                      "minSwitchInterval " .
                      "state_format " .
                      "number_format " .
                      "state_cmd1_gt " .
                      "state_cmd2_lt";
  }


##########################
sub
rateofchange_Define($$$)
{
  my ($hash, $def) = @_;
  my $cmd1_gt;
  my $cmd2_lt;

  # Get parameters
  my ($name, $type, $params, $actor) = split("[ \t]+", $def, 4);

  if (!defined($name) or !defined($type) or !defined($params)) {
    my $msg = "wrong syntax: define <name> rateofchange " .
              "<sensor>:<reading>:<timePeriod>:<minRate>:<maxRate>:<direction> " .
              "<actor>|<cmd1_gt>|<cmd2_lt>|<state_cmd1_gt>:<state_cmd2_lt>|state_format";
    return $msg if ($init_done);
  }
  
  # Params
  my ($sensor, $reading, $timePeriod, $minRate, $maxRate, $direction) = split(":", $params, 6);
  
  if(!$defs{$sensor}) {
    my $msg = "$name: Unknown sensor device $sensor specified";
    Log3 $name,2, $msg;
    return $msg if ($init_done);
  }
  
  $reading = "temperature" if (!defined($reading));
   
  # Default to 2minute calculation period
  if (!defined($timePeriod) or ($timePeriod eq "")) {
    $timePeriod=120;
  } elsif ($timePeriod !~ m/^[\d\.]*$/ ) {
      my $msg = "$name: value:$timePeriod, timePeriod needs a numeric parameter in seconds (greater than 5))";
      Log3 $name,2, $msg;
      return $msg if ($init_done);
  } elsif ($timePeriod < 5) {
    $timePeriod = 5;
  }
  
  # Default to 5% min rate of change
  if (!defined($minRate) or ($minRate eq "")) {
    $minRate=5;
  } elsif ($minRate !~ m/^[\d\.]*$/ ) {
      my $msg = "$name: value:$minRate, minRate needs a numeric parameter in percent";
      Log3 $name,2, $msg;
      return $msg if ($init_done);
  }
  
  # Default to 100% max rate of change
  if (!defined($maxRate) or ($maxRate eq "")) {
    $maxRate=100;
  } elsif ($maxRate !~ m/^[\d\.]*$/ ) {
      my $msg = "$name: value:$maxRate, maxRate needs a numeric parameter in percent";
      Log3 $name,2, $msg;
      return $msg if ($init_done);
  }
  
  # Default to positive rate of change
  if (!defined($direction) or ($direction eq "")) {
    $direction=1;
  } elsif ($direction !~ m/^[0-2]$/ ) {
      my $msg = "$name: value:$direction, direction needs a numeric parameter (0=both,1=up,2=down)";
      Log3 $name,2, $msg;
      return $msg if ($init_done);
  }  

  my @actorParams = split (/\|/,$actor);
  if (defined ($actorParams[0])) {
    if (!$defs{$actorParams[0]}) {
       my $msg = "$name: Unknown actor device $actorParams[0] specified";
       Log3 $name,2, $msg;
       return $msg if ($init_done);
    }
  }

  if (@actorParams == 1) { # no actor parameters
    if (!defined($actorParams[0])) {
       $attr{$name}{state_cmd1_gt}="off";
       $attr{$name}{state_cmd2_lt}="on";
       $attr{$name}{state_format} = "_sc";
    } else {
      $cmd1_gt = "set $actorParams[0] off";
      $cmd2_lt = "set $actorParams[0] on";
      $attr{$name}{state_cmd1_gt}="off";
      $attr{$name}{state_cmd2_lt} = "on";
      $attr{$name}{state_format} = "_sc";
      $attr{$name}{number_format} = "%.1f";
    }
  }
  else
  { 
    # actor parameters 
    $cmd1_gt = $actorParams[1] if (defined($actorParams[1]));
    $cmd2_lt = $actorParams[2] if (defined($actorParams[2]));
  }
  if (defined($actorParams[3])) {
    my ($st_cmd1_gt, $st_cmd2_lt) = split(":", $actorParams[3], 2);
    $attr{$name}{state_cmd1_gt} = $st_cmd1_gt if (defined($st_cmd1_gt));
    $attr{$name}{state_cmd2_lt} = $st_cmd2_lt if (defined($st_cmd2_lt));
    $attr{$name}{state_format} = "_sc";
  }
     
  if (defined($actorParams[4]))
  {
    $attr{$name}{state_format} = "_sc";
  }
  else
  {
    $attr{$name}{state_format} = "_sc";
    $attr{$name}{number_format} = "%.1f";
  }
  if (defined($actorParams[0]))
  {
    $cmd1_gt =~ s/@/$actorParams[0]/g;
    $cmd2_lt =~ s/@/$actorParams[0]/g;
  }
  
  $hash->{sensor} = $sensor;
  $hash->{sensor_reading} = $reading;
  $hash->{timePeriod} = $timePeriod;
  $hash->{minRate} = $minRate;
  $hash->{maxRate} = $maxRate;
  $hash->{direction} = $direction;
  $hash->{cmd1_gt} = SemicolonEscape($cmd1_gt);
  $hash->{cmd2_lt} = SemicolonEscape($cmd2_lt);
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
  $hash->{STATE} = 'initialized';
>>>>>>> 2057217a4... Add new module rateofchange
=======
>>>>>>> 6040306b9... Add new module rateofchange
=======
  $hash->{STATE} = 'initialized';
>>>>>>> aad97503b... Add new module rateofchange
=======
  $hash->{STATE} = 'initialized';
>>>>>>> 4166c18b3... Add new module rateofchange
  $hash->{calcIntervals} = 5;
  $hash->{INTERVAL} = $timePeriod/$hash->{calcIntervals}; # Min timePeriod is 5 so min interval is 1 second
  my @readingsBuf = ();
  $hash->{readingsBuffer} = \@readingsBuf;
  
  # Initialise readings
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  readingsSingleUpdate($hash, "state", "Initialized", 1);
=======
  readingsSingleUpdate($hash, "state", 0, 1);
>>>>>>> 2057217a4... Add new module rateofchange
=======
  readingsSingleUpdate($hash, "state", "Initialized", 1);
>>>>>>> 6040306b9... Add new module rateofchange
=======
  readingsSingleUpdate($hash, "state", 0, 1);
>>>>>>> aad97503b... Add new module rateofchange
=======
  readingsSingleUpdate($hash, "state", 0, 1);
>>>>>>> 4166c18b3... Add new module rateofchange
  rateofchange_set_state($hash);
  
  # Trigger first calculation cycle
  rateofchange_calculate($hash);
  
  return undef;
}

#####################################
# Undefine rateofchange device
sub rateofchange_Undefine($$)
{
  my ($hash,$arg) = @_;
  RemoveInternalTimer($hash);
  
  return undef;
}

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 4166c18b3... Add new module rateofchange
##########################
sub
rateofchange_Notify($$)
{
  my ($hash, $dev) = @_;
  my $pn = $hash->{NAME};
  return "" if(IsDisabled($pn));

  return rateofchange_calculate($hash);
}

<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 2057217a4... Add new module rateofchange
=======
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> 4166c18b3... Add new module rateofchange
=======
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
#####################################
# Calculate rateofchange
sub
rateofchange_calculate($)
{
  my ($hash) = @_;
  my $pn = $hash->{NAME};
  return "" if(IsDisabled($pn));

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  my $sensor_value = ReadingsVal("$hash->{sensor}", "$hash->{sensor_reading}", 0);
  $sensor_value =~ s/[^\d\.]//g;
  
  # Do nothing if we have no reading
  if (!defined($sensor_value) or ($sensor_value eq "") or ($sensor_value !~ m/^[\d\.]*$/ )) {
    Log3 ($hash, 5, "$hash->{NAME}_calculate: Invalid sensor reading for $hash->{sensor} ($hash->{sensor_reading}): $sensor_value");
=======
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 4166c18b3... Add new module rateofchange
  my $sensor_value = ReadingsVal($hash->{sensor}, $hash->{sensor_reading}, 0);
  
  # Do nothing if we have no reading
  if (!defined($sensor_value) or ($sensor_value eq "") or ($sensor_value !~ m/^[\d\.]*$/ )) {
    Log3 ($hash, 5, "$hash->{NAME}_calculate: Invalid sensor reading for $hash->{sensor} ($hash->{sensor_reading})");
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 2057217a4... Add new module rateofchange
=======
  my $sensor_value = ReadingsVal("$hash->{sensor}", "$hash->{sensor_reading}", 0);
  $sensor_value =~ s/[^\d\.]//g;
  
  # Do nothing if we have no reading
  if (!defined($sensor_value) or ($sensor_value eq "") or ($sensor_value !~ m/^[\d\.]*$/ )) {
    Log3 ($hash, 5, "$hash->{NAME}_calculate: Invalid sensor reading for $hash->{sensor} ($hash->{sensor_reading}): $sensor_value");
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
  my $sensor_value = ReadingsVal("$hash->{sensor}", "$hash->{sensor_reading}", 0);
  $sensor_value =~ s/[^\d\.]//g;
  
  # Do nothing if we have no reading
  if (!defined($sensor_value) or ($sensor_value eq "") or ($sensor_value !~ m/^[\d\.]*$/ )) {
    Log3 ($hash, 5, "$hash->{NAME}_calculate: Invalid sensor reading for $hash->{sensor} ($hash->{sensor_reading}): $sensor_value");
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> 4166c18b3... Add new module rateofchange
=======
  my $sensor_value = ReadingsVal("$hash->{sensor}", "$hash->{sensor_reading}", 0);
  $sensor_value =~ s/[^\d\.]//g;
  
  # Do nothing if we have no reading
  if (!defined($sensor_value) or ($sensor_value eq "") or ($sensor_value !~ m/^[\d\.]*$/ )) {
    Log3 ($hash, 5, "$hash->{NAME}_calculate: Invalid sensor reading for $hash->{sensor} ($hash->{sensor_reading}): $sensor_value");
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
    rateofchange_timer($hash);
    return undef;
  }

  # Fill buffer with values until we have a full set of readings
  if (@{$hash->{readingsBuffer}} < $hash->{calcIntervals}) {
    push @{$hash->{readingsBuffer}}, $sensor_value;
    Log3 ($hash, 4, "$hash->{NAME}_calculate: Added reading: $sensor_value to buffer. Total: ". @{$hash->{readingsBuffer}});
    rateofchange_timer($hash);
    return undef;    
  } elsif (@{$hash->{readingsBuffer}} > $hash->{calcIntervals}) {
    # Too many values in buffer
    shift @{$hash->{readingsBuffer}};
    Log3 ($hash, 4, "$hash->{NAME}_calculate: Too many values in buffer (@{$hash->{readingsBuffer}})");
    rateofchange_timer($hash);
    return undef;
  } else {
    # Got the correct number of values in buffer, remove one, add one new
    shift @{$hash->{readingsBuffer}};
    push @{$hash->{readingsBuffer}}, $sensor_value;
    Log3 ($hash, 4, "$hash->{NAME}_calculate: Pushed new reading to buffer ($sensor_value)");
  }
  
  # Got a full set of readings so calculate the rate of change
  # Calculate rateofchange using first and last values
  # rateofchange = ((now - past)/past)*100)
  my $rateofchange = (@{$hash->{readingsBuffer}}[4] - @{$hash->{readingsBuffer}}[0]);
  my $rateofchangeSec = $rateofchange/$hash->{timePeriod};
  
  # Update readings
  readingsBeginUpdate ($hash);
  readingsBulkUpdate  ($hash, "rateofchange",$rateofchange) 
    if (defined($rateofchange) and ($rateofchange ne ReadingsVal($pn,"rateofchange","")));
  readingsBulkUpdate  ($hash, "rateofchangePerSecond",$rateofchangeSec) 
    if (defined($rateofchangeSec) and ($rateofchangeSec ne ReadingsVal($pn,"rateofchangePerSecond","")));
  readingsBulkUpdate  ($hash, "sensor_value",$sensor_value) 
    if (defined($sensor_value) and ($sensor_value ne ReadingsVal($pn,"sensor_value","")));
  readingsEndUpdate ($hash, 1);

  # Which command to trigger?
  my $cmd_value = 1;
  # Both directions: Match on absolute value of rateofchange
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) >= $hash->{minRate}) 
    and (abs($rateofchange) <= $hash->{maxRate}));
   # Up only: match on positive rateofchange only
  $cmd_value = 0 if (($hash->{direction} == 1) and ($rateofchange >= $hash->{minRate}) 
    and ($rateofchange <= $hash->{maxRate}));
  # Down only: negate rate of change so we match on negative only
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) >= $hash->{minRate}) 
    and (-($rateofchange) <= $hash->{maxRate}));
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) > $hash->{minRate}) 
    and (abs($rateofchange) < $hash->{maxRate}));
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) >= $hash->{minRate}) 
    and (abs($rateofchange) <= $hash->{maxRate}));
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
   # Up only: match on positive rateofchange only
  $cmd_value = 0 if (($hash->{direction} == 1) and ($rateofchange >= $hash->{minRate}) 
    and ($rateofchange <= $hash->{maxRate}));
  # Down only: negate rate of change so we match on negative only
<<<<<<< HEAD
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) > $hash->{minRate}) 
    and (-($rateofchange) < $hash->{maxRate}));
>>>>>>> 2057217a4... Add new module rateofchange
=======
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) >= $hash->{minRate}) 
    and (-($rateofchange) <= $hash->{maxRate}));
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) > $hash->{minRate}) 
    and (abs($rateofchange) < $hash->{maxRate}));
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) >= $hash->{minRate}) 
    and (abs($rateofchange) <= $hash->{maxRate}));
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
   # Up only: match on positive rateofchange only
  $cmd_value = 0 if (($hash->{direction} == 1) and ($rateofchange >= $hash->{minRate}) 
    and ($rateofchange <= $hash->{maxRate}));
  # Down only: negate rate of change so we match on negative only
<<<<<<< HEAD
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) > $hash->{minRate}) 
    and (-($rateofchange) < $hash->{maxRate}));
>>>>>>> aad97503b... Add new module rateofchange
=======
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) >= $hash->{minRate}) 
    and (-($rateofchange) <= $hash->{maxRate}));
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) > $hash->{minRate}) 
    and (abs($rateofchange) < $hash->{maxRate}));
=======
  $cmd_value = 0 if (($hash->{direction} == 0) and (abs($rateofchange) >= $hash->{minRate}) 
    and (abs($rateofchange) <= $hash->{maxRate}));
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
   # Up only: match on positive rateofchange only
  $cmd_value = 0 if (($hash->{direction} == 1) and ($rateofchange >= $hash->{minRate}) 
    and ($rateofchange <= $hash->{maxRate}));
  # Down only: negate rate of change so we match on negative only
<<<<<<< HEAD
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) > $hash->{minRate}) 
    and (-($rateofchange) < $hash->{maxRate}));
>>>>>>> 4166c18b3... Add new module rateofchange
=======
  $cmd_value = 0 if (($hash->{direction} == 2) and (-($rateofchange) >= $hash->{minRate}) 
    and (-($rateofchange) <= $hash->{maxRate}));
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
  
  # Trigger actual command
  rateofchange_setValue($hash, $cmd_value);
  
  # Set next timer
  rateofchange_timer($hash);
  
  return undef;
}

#####################################
# Trigger command / set value
sub
rateofchange_setValue($$)
{
  my ($hash, $cmd_nr) = @_;
  my $pn = $hash->{NAME};
  return "" if(IsDisabled($pn));

  my $runtime = 0;
  my $maxRuntime;

  my @cmd_sym = ("cmd1_gt","cmd2_lt");
  
  # If we have a pending command use that instead of what was passed
  $cmd_nr = ReadingsVal($pn, "pendingCmd", 0) if ((ReadingsVal($pn, "pendingCmd", 0) > 0));
  
  Log3 ($hash, 4, "$hash->{NAME}_setValue: cmd_nr: $cmd_nr");

  # Update runtime if "cmd_gt" is active
  if (ReadingsVal($pn, "cmd", "") eq $cmd_sym[0])
  {
    $runtime = gettimeofday() - ReadingsVal($pn, "lastSwitch", 0);
    $maxRuntime = AttrVal($pn, "maxRuntime", 0);
    if (($runtime > $maxRuntime) and ($maxRuntime > 0))
    {
      # We've exceeded max runtime so set cmd to cmd2_lt
      Log3 ($hash, 5, "$hash->{NAME}_setValue: Max runtime ($maxRuntime) exceeded: (Runtime: $runtime)");
      $cmd_nr = 1;
      $runtime = 0;
    }
    else
    {
      Log3 ($hash, 5, "$hash->{NAME}_setValue: cmd1_gt Runtime: $runtime.");
      $cmd_nr = 0;
    }
  }

  my $cmd_sym_now = $cmd_sym[$cmd_nr];

  if (ReadingsVal($pn,"cmd","") ne $cmd_sym_now)
  {
    # Command has changed
    if ((ReadingsVal($pn, "lastSwitch", 0) + AttrVal($pn, "minSwitchInterval", 0)) > gettimeofday())
    {
      # We can't switch yet, store command as pending
      readingsSingleUpdate ($hash, "pendingCmd", $cmd_nr, 0);
      Log3 ($hash, 5, "$hash->{NAME}_setValue: Stored pending command: $cmd_nr");
      return;
    }
    my $ret=0;
    my @cmd =($hash->{cmd1_gt},$hash->{cmd2_lt});
    my @state_cmd = (AttrVal($pn,"state_cmd1_gt",""),AttrVal($pn,"state_cmd2_lt",""));
    my $cmd_now = $cmd[$cmd_nr];
    my $state_cmd_now = $state_cmd[$cmd_nr];
    if ($cmd_now ne "")
    {
      if ($ret = AnalyzeCommandChain(undef, $cmd_now))
      {
        Log3 ($hash, 2, "$hash->{NAME}_setValue: output of $pn $cmd_now: $ret");
      }
    }

    readingsBeginUpdate ($hash);
    readingsBulkUpdate ($hash, "cmd", $cmd_sym_now);
    # Set last switch time, we need this to ratelimit switching
    readingsBulkUpdate ($hash, "lastSwitch", gettimeofday());
    # Reset pendingCmd since we've just sent a cmd.
    readingsBulkUpdate ($hash, "pendingCmd", 0);
    readingsEndUpdate ($hash, 1);

    rateofchange_set_state($hash);
  }

  readingsSingleUpdate ($hash, "runtime", $runtime, 0);
}

#####################################
# Set state
sub 
rateofchange_set_state($)
{
    my ($hash) = @_;
    my $pn=$hash->{NAME};
    my $state_old = ReadingsVal($pn, "state","");
    my $sensor_value = ReadingsVal($pn,"sensor_value","");
    my $cmd = ReadingsVal($pn,"cmd","");
    my $state_cmd = AttrVal ($pn, "state_".$cmd,"");
    my $state_format = AttrVal($pn, "state_format", "_sc");
    my $number_format = AttrVal($pn, "number_format", "");
    if ($number_format ne "") {
      $sensor_value =sprintf($number_format,$sensor_value) if ($sensor_value ne "");
    }
    $state_format =~ s/\_s1v/$sensor_value/g;
    $state_format =~ s/\_sc/$state_cmd/g;
    if (($state_format) and ($state_old ne $state_format)) {
      readingsSingleUpdate ($hash, "state", $state_format, 1);
    }
}

#####################################
# Clear and start next timer
sub
rateofchange_timer($)
{
  my ($hash) = @_;

  # Remove any existing timers and trigger a new one
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
#  foreach my $args (keys %intAt) 
#  {
#    if (($intAt{$args}{ARG} eq $hash) && ($intAt{$args}{FN} eq 'rateofchange_calculate'))
#    {
#      Log3 ($hash, 5, "$hash->{NAME}_timer: Remove timer at: ".$intAt{$args}{TRIGGERTIME});
#      delete($intAt{$args});
#    }
#  }
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  # INTERVAL is in seconds, add to gettimeofday
  RemoveInternalTimer($hash);
=======
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 4166c18b3... Add new module rateofchange
  foreach my $args (keys %intAt) 
  {
    if (($intAt{$args}{ARG} eq $hash) && ($intAt{$args}{FN} eq 'rateofchange_calculate'))
    {
      #Log3 ($hash, 5, "$hash->{NAME}_timer: Remove timer at: ".$intAt{$args}{TRIGGERTIME});
      delete($intAt{$args});
    }
  }
  # INTERVAL is in seconds, add to gettimeofday
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 2057217a4... Add new module rateofchange
=======
  # INTERVAL is in seconds, add to gettimeofday
  RemoveInternalTimer($hash);
>>>>>>> 72834d5e5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
  # INTERVAL is in seconds, add to gettimeofday
  RemoveInternalTimer($hash);
>>>>>>> 00a5da330... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
=======
>>>>>>> 4166c18b3... Add new module rateofchange
=======
  # INTERVAL is in seconds, add to gettimeofday
  RemoveInternalTimer($hash);
>>>>>>> 33a843db5... Fixes.  Strip non-numeric data from sensor value. Less than or equal to, greater than or equal to in comparators for min/max rate.  Remove unused notify function
  InternalTimer(gettimeofday()+($hash->{INTERVAL}), "rateofchange_calculate", $hash, 0);
}

#####################################
# Attributes
sub
rateofchange_Attr(@)
{
  my ($command,$name,$attribute,$value) = @_;
  my $hash = $defs{$name};
  
  Log3 ($hash, 5, "$hash->{NAME}_Attr: Attr $attribute; Value $value");

  # Handle "disable" attribute
  if ($attribute eq "disable")
  {
    # Disable on 1, enable on anything else.
    if ($value eq "1")
    {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
      readingsSingleUpdate ($hash, "state", "disabled", 1);
    }
    else
    {
      readingsBeginUpdate ($hash);
      readingsBulkUpdate  ($hash, "state", "Initialized");
=======
=======
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 4166c18b3... Add new module rateofchange
      $hash->{STATE} = "disabled";
      readingsBeginUpdate ($hash);
      readingsBulkUpdate  ($hash, "state", "disabled");
      readingsEndUpdate   ($hash, 1);
<<<<<<< HEAD
<<<<<<< HEAD
=======
      readingsSingleUpdate ($hash, "state", "disabled", 1);
>>>>>>> 6040306b9... Add new module rateofchange
    }
    else
    {
      readingsBeginUpdate ($hash);
<<<<<<< HEAD
      readingsBulkUpdate  ($hash, "state", "initialized");
>>>>>>> 2057217a4... Add new module rateofchange
=======
      readingsBulkUpdate  ($hash, "state", "Initialized");
>>>>>>> 6040306b9... Add new module rateofchange
=======
=======
>>>>>>> 4166c18b3... Add new module rateofchange
    }
    else
    {
      $hash->{STATE} = "initialized";
      readingsBeginUpdate ($hash);
      readingsBulkUpdate  ($hash, "state", "initialized");
<<<<<<< HEAD
>>>>>>> aad97503b... Add new module rateofchange
=======
>>>>>>> 4166c18b3... Add new module rateofchange
      readingsBulkUpdate  ($hash, "cmd","wait for next cmd");
      readingsEndUpdate   ($hash, 1);
    }
  }
  elsif ($attribute eq "maxRuntime")
  {
    if ($value !~ m/^[0-86400]$/ )
    {
      return "maxRuntime is required in seconds [0-86400]";  
    }
  }
  elsif ($attribute eq "minSwitchInterval")
  {
    if ($value !~ m/^[0-86400]$/ )
    {
      return "minSwitchInterval is required in seconds [0-86400]";  
    }
  }

  return undef;
}

1;


=pod
=begin html

<a name="rateofchange"></a>
<h3>rateofchange</h3>
<ul>
  This module triggers actions based on how quickly a sensor value is changing.
  The most common implementation of this type of control is a Humidistat in a bathroom fan.
  Diverse controls can be realized by means of the module by evaluation of sensor data.
  This module reads any sensor that provides values in decimal and execute FHEM/Perl commands, if the value of the sensor is changing at a rate greater than a defined value.
  <br>
  <br>
  <br>
  Why not use THRESHOLD module?<br>
  Well, THRESHOLD works very well, but if you don't have an external humidity sensor it is difficult to maintain the same values year round.<br>
  For example, in the summer say normal humidity is 50% rising to 70% when the shower is run.  But in the winter normal humidity is 75% rising to 90% when the shower is run.  Using the summer values the fan runs all the time in winter, using the winter values the fan does not run at all in summer.
  <br>
  Some application examples are at the end of the module description.<br>
  <br>
  According to the definition of a module type rateofchange eg:<br>
  <br>
    <code>define &lt;name&gt; rateofchange &lt;sensor&gt; &lt;actor&gt;</code><br> 
  <br>
  </ul>
  <a name="rateofchangedefine"></a>
  <b>Define</b>
<ul>
  <br>
    <code>define &lt;name&gt; rateofchange &lt;sensor&gt;:&lt;reading&gt;:&lt;timePeriod&gt;:&lt;minRate&gt;:&lt;maxRate&gt;:&lt;direction&gt; &lt;actor&gt;|&lt;cmd1_gt&gt;|&lt;cmd2_lt&gt;|&lt;state_cmd1_gt&gt;:&lt;state_cmd2_lt&gt;|&lt;state_format&gt;</code><br>
  <br>
  <br>
    <li><b>sensor</b><br>
      a defined sensor in FHEM
    </li>
    <br>
    <li><b>reading</b> (optional)<br>
      reading of the sensor, which includes a value in decimal<br>
      default value: temperature
    </li>
    <br>
    <li><b>timePeriod</b> (optional)<br>
    Time period (seconds) over which the calculation is performed and rate of change is measured.<br>
    default value: 120
    </li>
    <br>
     <li><b>minRate</b> (optional)<br>
      Minimum rate of change (in percent) to trigger cmd1_gt.<br>
      default value: 5
    </li>
    <br>
    <li><b>maxRate</b> (optional)<br>
      Maximum rate of change (in percent) to trigger cmd1_gt.<br>
      default value: 100
    </li>
    <br>
    <br>
    <li><b>direction</b> (optional)<br>
    Direction of rate of change that will trigger cmd1_gt.<br>
    0 = both positive and negative change; 1 = positive (up) only; 2 = negative (down) only.<br>
    default value: 1
    </li>
    <br>
    <br>
    <li><b>actor</b> (optional)<br>
    actor device defined in FHEM
    </li>
    <br>
    <li><b>cmd1_gt</b> (optional)<br>
    FHEM/Perl command that is executed, if the rate of change is greater than minRate, less than maxRate and in the specified direction. @ is a placeholder for the specified actor.<br>
    default value: set actor off, if actor defined
    </li>
    <br>
    <li><b>cmd2_lt</b> (optional)<br>
    FHEM/Perl command that is executed, if the rate of change is less than minRate, greater than maxRate or not in the specified direction. @ is a placeholder for the specified actor.<br>
    default value: set actor on, if actor defined
    </li>
    <br>
    <li><b>state_cmd1_gt</b> (optional, is defined as an attribute at the same time and can be changed there)<br>
    state, which is displayed, if FHEM/Perl-command cmd1_gt was executed. If state_cmd1_gt state ist set, other states, such as active or deactivated are suppressed.
    <br>
    default value: none
    </li>
    <br>
    <li><b>state_cmd2_lt</b> (optional, is defined as an attribute at the same time and can be changed there)<br>
    state, which is displayed, if FHEM/Perl-command cmd1_gt was executed. If state_cmd1_gt state ist set, other states, such as active or deactivated are suppressed.
    <br>
    default value: none
    </li>
    <br>
    <li><b>state_format</b> (optional, is defined as an attribute at the same time and can be changed there)<br>
    Format of the state output: arbitrary text with placeholders.<br>
    Possible placeholders:<br>
    _s1v: sensor_value<br>
    _sc: state_cmd<br>
    Default value: _sc<br><br>
    </li>
    <br>
    <b><u>Examples:</u></b><br>
    <br>
    Example for Fan:<br>
    <br>	
    The humidity is 60%. When the shower is turned on the humidity increases to 90% over two minutes.<br>
    The fan should run for 30 minutes and should not be switched on/off more frequently than once a minute.<br>
    <br>
    <code>define humidistat rateofchange sensor:humidity:120:10:100:1 fan|set @ on|set @ off</code><br>
    <code>attr humidistat maxRuntime 1800</code><br>
    <code>attr humidistat minSwitchInterval 60</code><br>
    <br>
  </ul>

  <a name="rateofchangeset"></a>
  <b>Set </b>
  <ul>
      N/A
  </ul>
  <br>

  <a name="rateofchangeget"></a>
  <b>Get </b>
  <ul>
      N/A
  </ul>
  <br>

  <a name="rateofchangeattr"></a>
  <b>Attributes</b>
  <ul>
    <li><a href="#disable">disable</a></li>
    <li>maxRuntime</li>
    Set the maximum runtime for the actor.  Range 0-86400 seconds.  If not set the actor will switch off immediately after sensor value stops changing.
    <li>minSwitchInterval</li>
    Set the minimum time between switching. Range 0-86400 seconds.  Prevent rapid switching of the actor device.
    <li>state_cmd1_gt</li>
    <li>state_cmd2_lt</li>
    <li>state_format</li>
    <li>number_format</li>
    The specified format is used in the state for formatting Sensor_value (_s1v) using the sprintf function.<br>
    The default value is "% .1f" to one decimal place. Other formatting, see Formatting in the sprintf function in the Perl documentation.<br>
    If the attribute is deleted, numbers are not formatted in the state.<br>
  </ul>
  <br>
    
=end html
=cut
