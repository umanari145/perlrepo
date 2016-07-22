#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Syck;
use Dao::Items;
use Scraping::Base;
use Util::Debug;
use Util::DateUtil;
use Util::ArrayUtil;
use utf8;


my $conf_file = 'config.yaml';
my $config = YAML::Syck::LoadFile($conf_file);

my $hash ={
    'title' => "test"
};

#my $item_dao = Dao::Items->new( $config->{"main_db"});
#my $records = $item_dao->read(100);

my $croller = Scraping::Base->new( );

my $first_elements = &make_first_element;

my $hash_list = $croller->get_hash_list_from_element( $config->{"first_site"}->{"url"} , $first_elements );

my $arr_list = Util::ArrayUtil->convert_hashes_to_array( $hash_list );
#Util::Debug->debug( $arr_list);

for my $arr( @$arr_list ) {
    my $second_element = &make_second_element;

    my $contents_data  = $croller->get_hash_list_from_element( $arr->{"url"}, $second_element );
    Util::Debug->debug( $contents_data);
}


sub make_first_element{

    my @elements = ();

    push @elements ,{ "block" => ".thumb > a" ,  "attr" => '@href' ,  "name" => 'url[]' };
    push @elements ,{ "block" => ".thumb  img" , "attr" => '@src'  ,  "name" => 'image[]' };
    push @elements ,{ "block" => ".thumb img" ,  "attr" => '@alt' ,  "name" => 'movie_name[]' };

    return \@elements;
}

sub make_second_element{

     my @elements = ();

    push @elements ,{ "block" => "#player iframe",    "attr" => '@src' , "name" => 'movie_url' };
    push @elements ,{ "block" => "#main_video header ul li", "attr" => 'TEXT' , "name" => 'tag[]' };
#    push @elements ,{ "block" => "#player iframe", "attr" => '@src' , "name" => 'movie_url' };
    return \@elements;
}

