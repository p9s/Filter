#!/usr/bin/env perl
use Mojo::Base -base;
use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Mojo::Redis;

require_ok( 'Filter');

my $redis = Mojo::Redis->new("redis://192.168.31.21:6379/1");
my $filter = Filter->new(redis => $redis);

map {$filter->check('abbbbbf', 1);} 1 .. 1000;


done_testing();
