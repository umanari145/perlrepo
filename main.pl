#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Syck;
use originalDB;
use Util::DateUtil;
use utf8;

{
    package Data::Dumper;
    sub qquote { return shift; }
}

$Data::Dumper::Useperl = 1;

my $conf_file = 'config.yaml';
my $config = YAML::Syck::LoadFile($conf_file);


my $db = originalDB->new( $config->{"main_db"} );

my $items = $db->select( "items" );

my $hash ={
	'title' => "test"
};


$db->insert("items" , $hash);


#print Dumper $items;
