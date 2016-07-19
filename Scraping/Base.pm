#!/usr/bin/perl
package Scraping::Base;

use strict;
use warnings;
use URI;
use Data::Dumper;
use Dao::Items;
use Util::Debug;
use Util::DateUtil;
use Web::Scraper;
use utf8;


sub new {
	my $class = shift;

    my ( $url ) = @_;
    my $self = {};
    return bless $self , $class;
}

###
### ハッシュリストの取得
###
sub get_hash_list_from_element{

    my $self = shift;

    my( $url, $elements ) = @_;

    my $scraper = scraper {
        for my $element ( @$elements){
            process( $element->{"block"}, $element->{"name"}   => $element->{"attr"} );
        }
    };

    my $target_html = URI->new( $url );

    # 指定したURLに対して、スクレイピングを行います
    my $res  = $scraper->scrape( $target_html );

    return $res;

}

1;