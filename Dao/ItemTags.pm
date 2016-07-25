#!/usr/bin/perl
package Dao::ItemTags;

use strict;
use warnings;
use Dao::Base;
use base 'Dao::Base';
use Util::Debug;

sub new{
    my $self = shift->SUPER::new(@_);

    $self->set_table( "item_tags" );

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
sub regist_item_tag_id{

    my $self = shift;
    my ( $item_id,$tag_id_arr ) = @_;

    my @params = ();

    for my $tag_id ( @$tag_id_arr ) {
        my $item_tag_entity ={
            'item_id' => $item_id,
            'tag_id'  => $tag_id
        };
        push @params , $item_tag_entity;
    }

    $self->SUPER::insert_bulk( \@params );
}

1;