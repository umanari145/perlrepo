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
use WWW::Mechanize;
use LWP::UserAgent;

sub new {
    my $class = shift;

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

###
### 生のHTMLをそのまま取得するプログラム
###
sub get_row_HTML{

    my $self = shift;

    my( $url ) = @_;
    my  $mech =  WWW::Mechanize->new();
    $mech->get($url);
    return $mech->content();
}

sub get_donwload_image{

    my $self = shift;
    my( $image_url ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent('Mozilla/4.0');

    my $request = HTTP::Request->new('GET', $image_url);
    my $response = $ua->request($request);

    if($response->is_success){
        my $file = "/var/www/cgi-bin/practice/sample.img";
        open my $fh , '>', $file;
        binmode $fh;
        print $fh $response->content;
        close $fh;
        Util::Debug->debug( "image_download success ");
    }else{
        Util::Debug->debug( "image_donwload fail ");
    }

}

1;