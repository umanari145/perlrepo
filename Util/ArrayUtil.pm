#!/usr/bin/perl
package Util::ArrayUtil;

use strict;
use warnings;
use Data::Dumper;
use List::Util 'max';
use utf8;

{
    package Data::Dumper;
    sub qquote { return shift; }
}

$Data::Dumper::Useperl = 1;

###
### キー→配列となっているハッシュを配列化する
### 例 'key1' => ['aaa','bbbb']
###   'key2' => ['zzz','xxxx']
###  これを下記のように切り替える
###  ['key1' => 'aaa' , 'key2' => 'zzz']
###
sub convert_hashes_to_array{

    my $self = shift;
    my ( $hash_list )= @_;

    my @key_list_arr  = keys( %$hash_list );
    my $key_list      = \@key_list_arr;
    my $key_count     = scalar( @key_list_arr );
    #Util::Debug->debug( $key_list);

    #ハッシュ配列の最大数を取得する
    my  @arr0 = ();
    for my $key ( keys(%$hash_list) ){
    	push @arr0, scalar(@{$hash_list->{$key}});
    }
    my $max_hash_list_count = max @arr0;
    #Util::Debug->debug( $max_hash_list_count);

    my @arr = ();
    for( my $i = 0; $i < $max_hash_list_count ;$i++ ){
        my $hash;
        for my $key2 (@key_list_arr){
            $hash->{$key2} = $hash_list->{$key2}->[$i];
        }
        push @arr, $hash;
    }
    #Util::Debug->debug( \@arr );
    return \@arr;
}



1;