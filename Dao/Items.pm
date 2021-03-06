#!/usr/bin/perl
package Dao::Items;

use strict;
use warnings;
use Dao::Base;
use base 'Dao::Base';
use Util::Debug;

sub new{
    my $self = shift->SUPER::new(@_);
    $self->set_table( "items" );
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
### オリジナルコンテンツの重複があるかいなかのチェック
###
sub is_exist_original_contents{

    my $self = shift;
    my ( $original_contents_id ) = @_;

    my $where     = " original_contents_id ='" . $original_contents_id. "'";
    my $res_count = $self->SUPER::count( $where );

    return $res_count;
}



1;