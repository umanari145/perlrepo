#!/usr/bin/perl
package originalDB;

use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBIx::Custom;
use Util::DateUtil;
use utf8;


{
    package Data::Dumper;
    sub qquote { return shift; }
}

$Data::Dumper::Useperl = 1;


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
           AutoCommit          => 1,
           PrintError          => 1,
           RaiseError          => 1,
           ShowErrorStatement  => 1,
           AutoInactiveDestroy => 1
        }
    );

    my $self = {
        dbh => $dbh
    };

    return bless $self , $class;

}

sub select{

    my $self = shift;

    my ( $table ) =@_;

	my $result = $self->{dbh}->select( table=> $table );

	my @records;
	my $data_hash;

	while(my $row = $result->fetch_hash){
		push @records ,$row;
	}

	return \@records;
}

sub insert{

    my $self = shift;

    my ( $table, $hash ) = @_;

    $hash->{"created"}    = Util::DateUtil->date;
    $hash->{"modified"}   = Util::DateUtil->date;
    $hash->{"delete_flg"} = 0;

	my $result = $self->{dbh}->insert( $hash, table => $table  );

}
