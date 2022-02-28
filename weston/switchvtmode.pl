#!/usr/bin/perl

use strict;
use warnings;

sub Usage {
    print "Usage: switchvtmode.pl <N> <text|graphics>\n";
    print "       where 1 <= N <= 63\n";
    print "e.g. to switch tty1 to text mode, do:\n";
    print "       switchvtmode.pl 1 text\n";
}

if ($#ARGV != 1 ) {
    print "Error: Invalid no. of arguments.\n";
    Usage();
    exit 1;
}

if($ARGV[0] =~  /^[0-9]+$/) {
    if($ARGV[0] < 1 || $ARGV[0] > 63) {
        print "Error: Invalid tty no.\n";
        Usage();
        exit 1;
    }
} else {
    print "Error: tty no. should be numeric\n";
    Usage();
    exit 1;
}
    
if ($ARGV[1] ne 'text' && $ARGV[1] ne 'graphics') {
    print "Error: VT mode not supported\n";
    Usage();
    exit 1;
}

my $KDSETMODE = 0x4B3A;
my $KD_TEXT = 0;
my $KD_GRAPHICS = 1;

my $tty = "/dev/tty$ARGV[0]";
my $desired_mode = $ARGV[1];

if (-e $tty) {
    open(my $FD, ">", "$tty") or die "Can't open $tty: $!";

    if( $desired_mode eq 'text' ) {
        print "Switching VT mode of $tty to $desired_mode\n";
        ioctl($FD, $KDSETMODE, $KD_TEXT) or die "Could not set $desired_mode mode for $tty: $!";
    } elsif( $desired_mode eq 'graphics' ) {
        print "Switching VT mode of $tty to $desired_mode\n";
        ioctl($FD, $KDSETMODE, $KD_GRAPHICS) or die "Could not set $desired_mode mode for $tty: $!";
    }
    close $FD or die "$FD: $!";
} else {
    print "$tty does not exist\n";
    exit 1;
}
