#!/usr/bin/perl
package Dao::Tags;

use strict;
use warnings;
use Dao::Base;
use base 'Dao::Base';
use Util::Debug;

sub new{
    my $self = shift->SUPER::new(@_);

    $self->set_table( "tags" );

    return $self;
}


sub select{

    my $self = shift;
    my $records = $self->SUPER::select();

    return $records;
}

sub read{

    my $self = shift;
    my ( $id ) = @_;
    my $records = $self->SUPER::read($id);

    return $records;
}

###
### タグの文字列からidを取得する
###
sub get_tag_id_by_tag_str{

    my $self = shift;
    my ( $tag_str ) = @_;

    my $column = " id";
    my $where  = " tag = '" .$tag_str ."' and show_tag = 0";
    my $res = $self->SUPER::select( $column, $where );

    if( $res && scalar(@$res) > 0 ) {
        return $res->[0];
    }else {
        return 0;
    }
}

1;