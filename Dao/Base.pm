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

    my ( $database_config ) = @_;

    my $datasource = $database_config->{"datasource"};
    my $host       = $database_config->{"host"};
    my $database   = $database_config->{"database"};
    my $password   = $database_config->{"password"};
    my $user       = $database_config->{"user"};

    my $dbh = DBIx::Custom->connect(
        dsn      =>   "dbi:" . $datasource . ":database=" . $database. ";host=". $host .";port=3306",
        password => $password,
        user     => $user,
        option   => {
           mysql_enable_utf8   => 1,
           AutoCommit          => 0,
           PrintError          => 1,
           RaiseError          => 1,
           ShowErrorStatement  => 1,
           AutoInactiveDestroy => 1
        }
    );

    my $self = {
        dbh   => $dbh
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
    $select_hash->{where}->{"delete_flg"} = 0;

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
    my ( $table , $hash ) = @_;

    $hash->{"created"}    = Util::DateUtil->date;
    $hash->{"modified"}   = Util::DateUtil->date;
    $hash->{"delete_flg"} = 0;

    my $result = $self->{dbh}->insert( $hash, table => $table  );
    $self->query_log;
}

1;