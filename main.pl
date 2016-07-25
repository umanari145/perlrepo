#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Syck;
use DBI;
use DBIx::Custom;
use Dao::Items;
use Dao::Tags;
use Dao::ItemTags;
use Scraping::Base;
use Util::Debug;
use Util::DateUtil;
use Util::ArrayUtil;
use utf8;


my $conf_file = 'config.yaml';
my $config = YAML::Syck::LoadFile($conf_file);
my $dbobj = &connetct_dbh( $config->{"main_db"});

my $croller = Scraping::Base->new();
$croller->get_donwload_image("http://coolship100.net/wp-content/uploads/2015/01/sasiko4.jpeg" );
exit;
my $first_elements = &make_first_element;
my $hash_list = $croller->get_hash_list_from_element( $config->{"first_site"}->{"url"} , $first_elements );

my $data_arr = Util::ArrayUtil->convert_hashes_to_array( $hash_list );

&decorate_list( $data_arr );
#Util::Debug->debug( $data_arr);

for my $data ( @$data_arr ) {
    my $second_element = &make_second_element;
    my $contents_data  = $croller->get_hash_list_from_element( $data->{"contents_url"}, $second_element );

    my $tag_id_arr = &extract_other_data( $contents_data );
    #Util::Debug->debug( $tag_id_arr );
    my $item_entity = &make_item_entity( $data , $contents_data );
    #Util::Debug->debug( $item_entity);
    &regist_item( $item_entity, $tag_id_arr );
}
&commit_dbh;


sub connetct_dbh{

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

    return {
        database => $database,
        dbh      => $dbh
    };
}

sub commit_dbh{
	$dbobj->{dbh}->commit;
}

###
### 商品の登録
###
sub regist_item{

    my ( $item_entity, $tag_id_arr ) = @_;

    my $item_dao      = Dao::Items->new( $dbobj );
    my $item_tags_dao = Dao::ItemTags->new( $dbobj );

	my $is_exist_original_contents = $item_dao->is_exist_original_contents( $item_entity->{"original_contents_id"} );
	#Util::Debug->debug( $is_exist_original_contents );

    if( !$is_exist_original_contents){
        my $item_id = $item_dao->insert( $item_entity );
	    $item_tags_dao->regist_item_tag_id( $item_id,$tag_id_arr)
	    #Util::Debug->debug( $id );
    }
}

###
### URLの置換
###
sub extract_other_data{

    my ( $contents_data ) = @_;

    if( $contents_data->{"movie_url"} =~ /^.*?\.php\?id=(\w+)=.*?$/ ) {
        $contents_data->{"original_contents_id"} = $1;
    }
    #Util::Debug->debug( $contents_data);
    my $tag_id_arr = &get_tag_id_arr( $contents_data->{"tag"});
    return $tag_id_arr;
}

###
### タグの文字列からidを取得する
###
sub get_tag_id_arr{

    my ( $tag_str_arr ) =@_;

    my $tag_dao = Dao::Tags->new( $dbobj );

    my @tag_id_arr = ();
    for my $tag_str (@$tag_str_arr ){
        my $tag_id =  $tag_dao->get_tag_id_by_tag_str( $tag_str);
        if( $tag_id && $tag_id->{"id"} ) {
            push @tag_id_arr , $tag_id->{"id"};
        }
    }
    return \@tag_id_arr;
}

###
###
###
sub make_item_entity{
    my ( $data, $contents_data ) =@_;

    my $item_entity  = {
        'original_id'          => $data->{"original_id"},
        'title'                => $data->{"title"},
        'volume'               => $data->{"time"},
        'movie_url'            => $contents_data->{"movie_url"},
        'original_contents_id' => $contents_data->{"original_contents_id"},
        'delete_flg'           => 0
    };
}


###
### 一回目の値の取得のHTMLの構造
###
sub make_first_element{

    my @elements = ();

    push @elements ,{ "block" => ".thumb > a" ,      "attr" => '@href' ,  "name" => 'contents_url[]' };
    push @elements ,{ "block" => ".thumb  img" ,     "attr" => '@src'  ,  "name" => 'image[]' };
    push @elements ,{ "block" => ".thumb img" ,      "attr" => '@alt' ,   "name" => 'title[]' };
    push @elements ,{ "block" => ".thumb .duration" ,"attr" => 'TEXT' ,   "name" => 'time[]' };

    return \@elements;
}

###
### 2回目の値の取得のHTMLの構造
###
sub make_second_element{

     my @elements = ();

    push @elements ,{ "block" => "#player li",               "attr" => 'HTML' , "name" => 'movie_url' };
    push @elements ,{ "block" => "#main_video header ul li", "attr" => 'TEXT' , "name" => 'tag[]' };
    return \@elements;
}

###
### 3回目の値の取得のHTMLの構造
###
sub make_third_element{

    my @elements = ();
    push @elements ,{ "block" => "#title > p", "attr" => 'TEXT' , "name" => 'tekisuto[]' };
    return \@elements;
}

sub decorate_list{

    my ( $data_arr ) = @_;

    for my $data ( @$data_arr ) {
        $data->{"contents_url"} =~ /^.*?id=(\d+)$/;
        if( $1 ) {
            $data->{"original_id"} = "p" . $1;
        }
    }
}

