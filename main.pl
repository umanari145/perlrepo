#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Syck;
use Dao::Items;
use Util::Debug;
use Util::DateUtil;
use utf8;


my $conf_file = 'config.yaml';
my $config = YAML::Syck::LoadFile($conf_file);

my $hash ={
    'title' => "test"
};

my $item_dao = Dao::Items->new( $config->{"main_db"});
my $records = $item_dao->select;
Util::Debug->debug( $records );
