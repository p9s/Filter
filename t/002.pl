#!/usr/bin/env perl
use Mojo::Base -base;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Digest::MD5 qw/md5_hex/;
use bigint;
use Digest::SHA qw(sha1);
use Mojo::Redis;
use Filter;
#my $size = 512 * 1024 * 1024 * 8;


#map {md5_hex('bala0')} 1 .. 10000000;
#map {sha1('bala0')} 1 .. 10000000;


my $redis = Mojo::Redis->new("redis://192.168.31.21:6379/1");
my $filter = Filter->new(redis => $redis);
#$redis->db->del($filter->redis_key);

my $check = $filter->_check_sign(2147483648);
say $check;

done_testing();
