#!/usr/bin/perl
package Dao::Base;

use strict;
use warnings;
use DBI;
use DBIx::Custom;
use Util::Debug;
use Util::DateUtil;
use utf8;


sub new {

    my $class = shift;

    my ( $dbobj ) = @_;

    my $self = {
        dbh      => $dbobj->{dbh},
        database => $dbobj->{database}
    };

    return bless $self , $class;

}

sub set_table{

    my $self = shift;
    my ( $table ) = @_;

    $self->{table} = $table;
}

###
### 通常のSelect文を発行
###
sub select{

    my $self = shift;

    my ( $columns, $where ) = @_;

    my $select_hash;
    $select_hash->{table}  = $self->{table};
    $select_hash->{column} = ( defined( $columns) ) ? $columns: "*" ;

    if( defined( $where ) ) {
        $select_hash->{where} = $where;
    };

    my $result;
    $result = $self->{dbh}->select( %$select_hash );

    my @records;
    my $data_hash;

    while(my $row = $result->fetch_hash){
        push @records ,$row;
    }
    $self->query_log;
    return \@records;
}

###
### 通常のcount文を発行
###
sub count{

    my $self = shift;

    my ( $where ) = @_;

    my $select_hash;
    $select_hash->{table}  = $self->{table};

    if( defined( $where ) ) {
        $select_hash->{where} = $where;
    };

    my $result;
    $result = $self->{dbh}->count( %$select_hash );
    $self->query_log;
    return $result;
}

###
### SQLのログを取得
###
sub query_log{

    my $self = shift;
    my $last_sql = $self->{dbh}->last_sql;
    Util::Debug->debug( $last_sql );

}

###
### プライマリキーで取得
###
sub read{

    my $self = shift;
    my ( $id ) = @_;
    my $table  = $self->{table};

    if( !defined( $id )) {
        die("undefined id")
    }

    my $record = $self->{dbh}->select(
        table => $table,
        where => {
            id         => $id,
            delete_flg => 0
        }
    )->fetch_hash_one;
    $self->query_log;
    return $record;

}

sub insert{

    my $self = shift;
    my ( $hash ) = @_;

    my $table = $self->{table};
    $hash->{"created"}    = Util::DateUtil->date;
    $hash->{"modified"}   = Util::DateUtil->date;

    my $result = $self->{dbh}->insert( $hash, table => $table  );
    $self->query_log;
    if( $result ) {
        return $self->{dbh}->last_insert_id( $self->{database}, $self->{database}, $table, "id");
    }
}

sub insert_bulk{
    my $self = shift;
    my ( $arr ) = @_;

    my $table = $self->{table};

    for my $data ( @$arr) {
        $data->{"created"}    = Util::DateUtil->date;
        $data->{"modified"}   = Util::DateUtil->date;
    }

    my $res = $self->{dbh}->insert( $arr , table => $table, bulk_insert => 1);
    $self->query_log;
    return $res;
}

1;