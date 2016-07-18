#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util 'max';

my @arr=(2,4,5,7,8);

print grep{ $_% 2 == 0 }@arr;
#248
print "\n";

#下記と同じ
for my $v(@arr){
	if( $v %2 == 0 ){
		print $v;
	}
}

print "\n";

# phpでいうin_array
@arr = ("hoge","foo","bar");
my $var = 'hoge';

if( grep {$_ eq $var} @arr){
	print "in_array";
}
#in_array
print "\n";

$var="hogehoge";
if( grep {$_ eq $var} @arr){
	print "in_array";
}
#何も表示されない

#http://dqn.sakusakutto.jp/2011/08/perl_10.html


#array_unique
my %count;
@arr =("hoge","foo","bar","hoge");
@arr = grep{ !$count{$_}++ }@arr;
print Dumper \@arr;

#$VAR1 = [
#          'hoge',
#          'foo',
#          'bar'
#        ];

#上記が何をやっているかについて知りたい方はこちら↓説明がパーフェクト
#http://troubledkumi.blog85.fc2.com/blog-entry-5.html


#実務で一番使うハッシュ型の配列への応用
print "\n";
my $hash_arr =[
	{"name"=>"kazumi","age"=>"30","pref"=>"chiba"},
	{"name"=>"ichirou","age"=>"18","pref"=>"tokyo"},
	{"name"=>"yuusuke","age"=>"25","pref"=>"chiba"},
	{"name"=>"satoshi","age"=>"45","pref"=>"kanagawa"},
	{"name"=>"jirou","age"=>"9","pref"=>"tokyo"}
];

#応用系その１
#30才以上のデータを取り出す

#下記で一気に取り出せる
my @arr2 = grep{ $_->{"age"} >= 30 } @$hash_arr;
print Dumper @arr2;

#$VAR1 = {
#          'pref' => 'chib',
#          'name' => 'ichiro',
#          'age' => 30
#        };
#$VAR2 = {
#          'pref' => 'kanagawa',
#          'name' => 'shirou',
#          'age' => 45
#        };

print "\n";

#応用系 その２
#名前にrouが入っている人間の合計を出す
my @arr3 = grep{ $_->{"name"} =~ /rou/  } @$hash_arr;
my $sum;
$sum += $_->{"age"} for @arr3;
print "sum" . $sum;
#27 ichirouとjirou

#http://d.hatena.ne.jp/perlcodesample/20100119/1264257759

print "\n";



#応用系3 県ごとにクルーピング
my @pref_arr=();
#県情報だけを全て取得
push @pref_arr , $_->{"pref"} for @$hash_arr;

#uniqにする
my %count2;
my @pref_arr2 = grep{ !$count2{$_}++ }@pref_arr;

#それぞれをキーにしたハッシュを作る
my $pref_hash;
for my $pref_val (@pref_arr2){
	$pref_hash->{$pref_val} =undef;
}

#県がhashになっているものを格納していく
for my $person_hash (@$hash_arr){

    my $pref_key = $person_hash->{"pref"};
	my @tmp_data_arr=();

	if( !$pref_hash->{$pref_key}){
		push (@tmp_data_arr ,$person_hash);
	}else{
		my $tmp_data_arr_ref = $pref_hash->{$pref_key};
		@tmp_data_arr = @$tmp_data_arr_ref;
		push( @tmp_data_arr ,$person_hash);
	}
	$pref_hash->{$pref_key} = \@tmp_data_arr;
}

print Dumper $pref_hash;

#$VAR1 = {
#          'tokyo' => [
#                       {
#                         'pref' => 'tokyo',
#                         'name' => 'ichirou',
#                         'age' => 18
#                       },
#                       {
#                         'pref' => 'tokyo',
#                         'name' => 'jirou',
#                         'age' => 9
#                       }
#                     ],
#          'kanagawa' => [
#                          {
#                            'pref' => 'kanagawa',
#                            'name' => 'satoshi',
#                            'age' => 45
#                          }
#                        ],
#          'chiba' => [
#                       {
#                         'pref' => 'chiba',
#                         'name' => 'kazumi',
#                         'age' => 30
#                       },
#                       {
#                         'pref' => 'chiba',
#                         'name' => 'yuusuke',
#                         'age' => 25
#                       }
#                     ]
#        };



#List::Util
#max
@arr=(20,50,30);
my $max_val = max @arr;
print "max". $max_val;
#50

#他にmin(最小値),sum 合計値などもあり


#参考リンク
#http://d.hatena.ne.jp/minesouta/20070914/p1

print "\n";

#網羅性は一番
#http://d.hatena.ne.jp/perlcodesample/20091025/1252196591