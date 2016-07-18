#!/usr/bin/perl
package Util::DateUtil;

use strict;
use warnings;
use Time::Piece;
use Data::Dumper;

sub date {

    my $self = shift;

    my ( $target_time , $format ) = @_;

    my $time = localtime;

    if( !$format ) {
        $format = '%Y-%m-%d %H:%M:%S';
    }

    if( $target_time ){
        return $time->strftime( $target_time, $format);
    } else {
        return $time->strftime( $format );
    }
}

1;