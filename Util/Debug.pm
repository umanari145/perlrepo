#!/usr/bin/perl
package Util::Debug;

use strict;
use warnings;
use Data::Dumper;
use utf8;

{
    package Data::Dumper;
    sub qquote { return shift; }
}

$Data::Dumper::Useperl = 1;

sub debug{
    my $self = shift;

    my ( $val ) = @_;

	print Dumper $val;
}

1;