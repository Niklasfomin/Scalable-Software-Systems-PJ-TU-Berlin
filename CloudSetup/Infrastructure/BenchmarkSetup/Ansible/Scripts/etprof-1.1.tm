# etprof - trivial exclusive time profiler
# I wrote this because my feeling is that exclusiveRunTime info
# of the TclLib's profiler is broken.
#
# Usage: source it as first line in your application
#        and check the standard output for profiling information
#        at runtime.
#
# Copyright (C) 2004 Salvatore Sanfilippo
#
#etprof 1.0 posted at https://wiki.tcl-lang.org/page/etprof
#https://wiki.tcl-lang.org/license
#Tcl and extensions such as Tk, Expect, tcllib are distributed under the terms of this license, a BSD-type license, which is much less restrictive than the GPL.
#It is safe to assume that any code posted on this Wiki (or that you post on this wiki) is, unless otherwise explicitly specified, under the same license.
#
# etprof 1.1 modifications from original Copyright (C) 2019 Steve Shaw under HammerDB License
#
package provide etprof 1.1

 namespace eval ::etprof {}

 # Unset the specified var and returns the old content
 proc ::etprof::getunset varName {
     upvar $varName var
     set t $var
     unset var
     return $t
 }

 proc ::etprof::lpop listVar {
     upvar $listVar list
     set retval [lindex $list end]
     set list [lrange [::etprof::getunset list] 0 end-1]
     return $retval
 }

 proc ::etprof::TraceHandler {name cmd args} {
     # We need to measure the elapsed time as early as possible.
     set enter_clicks [clock clicks]
     set enter_secs [clock seconds]
     set elapsed [expr {$enter_clicks-$::etprof::timer}]
     set seconds [expr {$enter_secs-$::etprof::timersecs}]

     #####################################################################
     # Starting from this point it's possible to do potentially slow
     # operations. They will not be accounted as time spent in procedures
     #####################################################################
     # The following is a flag that may be turned on inside [switch].
     # If true the [clock clicks] value will be added to the cumulative_timers
     # list as later as possible before to exit this function.
     set non_recursive_enter 0;
     switch -- [lindex $args end] {
        enter {
            # Try to guess the caller function. If we are at toplevel
            # set it to TOPLEVEL, in the hope there isn't another function
            # with this name.
            if {[info level] == 1} {
                set caller TOPLEVEL
            } else {
                # Otherwise use [info level] to get the caller name.
                set caller [lindex [info level -1] 0]
                set callerns [uplevel 1 namespace current]
                set caller [::etprof::fullyQualifiedName $caller $callerns]
            }

            set depth [incr ::etprof::depth($name)]
            ::etprof::enterHandler $name $caller $elapsed
            if {$depth == 1} {
                set non_recursive_enter 1
            }
        }
        leave {
            if {$::etprof::depth($name) == 1} {
                set t [lpop ::etprof::cumulative_timers]
                set cum_elapsed [expr {$enter_clicks-$t}]
                incr ::etprof::cumulative($name) $cum_elapsed
#intermediate percentile measurements
        if {![string match {::tcl*} $name]} {
#add to list of elapsed times per name for 2 seconds
                lappend ::etprof::pctiles($name) $elapsed
                if {[ expr $seconds % 2 ] eq 0 } {
                if { $::etprof::iterations != $seconds } {
                set ::etprof::iterations $seconds
#calculate and print percentiles
                ::etprof::printPercentiles $seconds
                                        }
                                } 
                        }
#intermediate percentile measurements
                }
            ::etprof::leaveHandler $name $elapsed
            incr ::etprof::depth($name) -1
        }
     }

     #####################################################################
     # Don't add slow operations after this comment.
     # The following lines should only be used to get [clock clicks]
     # values at near as possible to the leave from this function.
     #####################################################################

     # Add the time spent inside the handler to every element
     # of the cumulative timers list. Note that the time needed
     # to perform the following operation will be accounted to user code
     # as cumulative, but from worst-case tests performed this does not
     # seems to alter the output in a significant way.
     if {[llength $::etprof::cumulative_timers]} {
        set spent [expr {[clock clicks]-$enter_clicks}]
        foreach t $::etprof::cumulative_timers {
            lappend newlist [expr {$t+$spent}]
        }
        set ::etprof::cumulative_timers $newlist
     }
     # Note that we take the 'timer' sample as the last operation.
     # Basically this profiler try to be more accurate in
     # the exclusive measure.
     if {$non_recursive_enter} {
                lappend ::etprof::cumulative_timers [clock clicks]
     }
     set ::etprof::timer [clock clicks]
 }

 proc ::etprof::enterHandler {name caller elapsed} {
     # The caller may not exists in the arrays because may be a built-in
     # like [eval].
     if {[info exists ::etprof::exclusive($caller)]} {
        incr ::etprof::exclusive($caller) $elapsed
     }
     incr ::etprof::calls($name)
 }

 proc ::etprof::leaveHandler {name elapsed} {
     # The program is leaving the function. Add the current time value
     # to it. And reset the value.
     incr ::etprof::exclusive($name) $elapsed
 }

 # That comes from the TclLib's profiler, seems working but
 # I wonder if there is a better (faster) way to get the fully-qualified
 # names.
 proc ::etprof::fullyQualifiedName {name ns} {
     if { ![string equal $ns "::"] } {
        if { ![string match "::*" $name] } {
            set name "${ns}::${name}"
        }
     }
     if { ![string match "::*" $name] } {
        set name "::$name"
     }
     return $name
 }

 # That comes from the TclLib's profiler, seems working but
 # I wonder if there is a better way to get the fully-qualified
 # name of the procedure to create without pattern matching.
 proc ::etprof::profProc {name arglist body} {
     # Get the fully qualified name of the proc
     set ns [uplevel [list namespace current]]
     set name [::etprof::fullyQualifiedName $name $ns]
     # If the proc call did not happen at the global context and it did not
     # have an absolute namespace qualifier, we have to prepend the current
     # namespace to the command name
     if { ![string equal $ns "::"] } {
        if { ![string match "::*" $name] } {
            set name "${ns}::${name}"
        }
     }
     if { ![string match "::*" $name] } {
        set name "::$name"
     }

     uplevel 1 [list ::etprof::oldProc $name $arglist $body]
     trace add execution $name {enter leave} \
              [list ::etprof::TraceHandler $name]
     ::etprof::initProcInfo $name
     return
 }

 proc ::etprof::initProcInfo name {
     set ::etprof::calls($name) 0
     set ::etprof::exclusive($name) 0
     set ::etprof::cumulative($name) 0
     set ::etprof::depth($name) 0
     set ::etprof::pctiles($name) 0
 }

 proc ::etprof::init {} {
     rename ::proc ::etprof::oldProc
     rename ::etprof::profProc ::proc
     set ::etprof::timer [clock clicks]
     set ::etprof::timersecs [clock seconds]
     set ::etprof::iterations 0
     set ::etprof::hits 0
     array set ::etprof::exclusive {}
     array set ::etprof::cumulative {}
     array set ::etprof::calls {}
     set ::etprof::cumulative_timers {}
     ::etprof::initProcInfo TOPLEVEL
     set ::etprof::calls(TOPLEVEL) 1
     set ::etprof::cumulative(TOPLEVEL) {NOT AVAILABLE}
     return
 }

 proc ::etprof::printInfoLine {name exTot exTotPerc callsNum avgExPerCall cumulTot {sep |}} {
set name2 [string trimleft $name "::" ]
     puts [format "$sep%-17.17s$sep%14.14s$sep%6.6s$sep%8.8s$sep%14.14s$sep%14.14s$sep" \
        $name2 $exTot $exTotPerc% $callsNum $avgExPerCall $cumulTot]
 }

 proc ::etprof::printInfoSeparator {} {
     set hline [string repeat - 30]
     ::etprof::printInfoLine $hline $hline $hline $hline $hline $hline +
 }

 proc ::etprof::percentage {part total} {
     set p [expr {($part*100.0)/$total}]
     format "%.02f" $p
 }

proc ::etprof::percentile {pvalues percent} {
proc is_whole { float } {
  return [expr abs($float - int($float)) > 0 ? 0 : 1]
}
set k [ expr [ llength $pvalues ] * $percent ]
if { [ is_whole $k ] } {
set kint [ expr int($k) ]
set pctile [ expr ([lindex $pvalues [ expr $kint - 1 ]] + [lindex $pvalues $kint ]) / 2.0 ]
if { [ is_whole $pctile ] } {
set pctile [ expr int($pctile) ]
                }
        } else {
set k [ expr round($k) ]
set pctile [ lindex $pvalues [ expr $k - 1 ]]
        }
return $pctile
}

proc ::etprof::printPercentiles { seconds } {
puts "|PERCENTILES [clock format [ expr $::etprof::timersecs + $seconds - 2 ] -format {%Y-%m-%d %H:%M:%S}] to [clock format [ expr $::etprof::timersecs + $seconds ] -format {%Y-%m-%d %H:%M:%S}]"
     foreach {key val} [array get ::etprof::exclusive] {
if {[string match {::tcl*} $key]||[string match {::msgcat*} $key]||[string match {::etprof*} $key]} {
                ;
        } else {
        lappend info [list $key $val]
        }
     }
     set info [lsort -decreasing -index 1 -integer $info]
     foreach i $info {
        foreach {name exclusiveTime} $i break
unset -nocomplain sortedset
set sortedset [ lsort -integer $::etprof::pctiles($name) ]
set ::etprof::pctiles($name) 0
set numvalues [ llength $sortedset ]
if { $numvalues > 1 }  {
set sortedset [ lreplace $sortedset 0 0 ]
set minv [ lindex $sortedset 0 ]
set maxv [ lindex $sortedset end ]
set p99 [ ::etprof::percentile $sortedset 0.99 ]
set p95 [ ::etprof::percentile $sortedset 0.95 ]
set p50 [ ::etprof::percentile $sortedset 0.50 ]
set name2 [string trimleft $name "::" ]
puts "|$name2|MIN-$minv|P50%-$p50|P95%-$p95|P99%-$p99|MAX-$maxv|SAMPLES-$numvalues"
                }
set ::etprof::pctiles($name) 0
        }
     ::etprof::printInfoSeparator
 }

 proc ::etprof::printLiveInfo {} {
     set info {}
     foreach {key val} [array get ::etprof::exclusive] {
if {[string match {::tcl*} $key]||[string match {::msgcat*} $key]||[string match {::etprof*} $key]} {
                ;
        } else {
        lappend info [list $key $val]
        }
     }
     set info [lsort -decreasing -index 1 -integer $info]
     ::etprof::printInfoSeparator
     ::etprof::printInfoLine PROCNAME EXCLUSIVETOT {} CALLNUM AVGPERCALL CUMULTOT
     ::etprof::printInfoSeparator
     # Sum all the exclusive times to print infos in percentage
     set totalExclusiveTime 0
     foreach i $info {
        foreach {name exclusiveTime} $i break
        incr totalExclusiveTime $exclusiveTime
     }
     foreach i $info {
        foreach {name exclusiveTime} $i break
        set cumulativeTime $::etprof::cumulative($name)
        set calls $::etprof::calls($name)
        if {$calls} {
            set avgTimePerCall [expr {int($exclusiveTime/$calls)}]
        } else {
            set avgTimePerCall 0
        }
        if {$::etprof::depth($name)} {
            set cumulativeTime "(*)$cumulativeTime"
        }
        ::etprof::printInfoLine $name $exclusiveTime [::etprof::percentage $exclusiveTime $totalExclusiveTime] $calls $avgTimePerCall $cumulativeTime
     }
     ::etprof::printInfoSeparator
 }
::etprof::init
