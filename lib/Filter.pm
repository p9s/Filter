package Filter;
use Mojo::Base -base;
use Digest::MD5 qw/md5_hex/;
use Carp;
use Data::Dumper;

# hash -> int -> 求余 -> 检查 redis 相应位
has redis => undef, weak => 1;
has redis_key => 'perl_boolm_filter';

has sign_size => 5;

# 512MB
has filter_size => 512 * 1024 * 1024 * 8;

# 存在 返回: 1,  不存在返回: 0
# is_do_cache: 如果在这里同时进行存储, 这样就不用
# 再单独计算一次 sign
sub check {
  my ($c, $str, $is_do_cache) = @_;

  # 如果没有 redis, 则全部返回不存在
  unless ($c->redis) {
    carp 'redis not found';
    return 0;
  }

  my $signs = $c->_sign($str);
  #say Dumper($signs);

  # 检查每一位, 如果任何一位是 0, 则停止
  my $is_sign_exists = 1;
  foreach my $sign ( @$signs) {
    $is_sign_exists = $c->_check_sign($sign);
    # say "is_sign_exists: $is_sign_exists";
    last unless $is_sign_exists;
  }

  map {$c->_cache_sign($_, 1); say 'ff' } @$signs
    if $is_do_cache && $is_sign_exists == 0;
  return $is_sign_exists;
}

sub _check_sign {
  my ($c, $sign) = @_;
  my $is_exists = $c->redis->db->getbit($c->redis_key, $sign);
  return $is_exists;
}

sub _cache_sign {
  my ($c, $sign, $value) = @_;
  $c->redis->db->setbit($c->redis_key, $sign, $value);
}

sub _sign {
  my ($c, $str) = @_;

  my @signs;

  map {
    my $sign_str = sprintf "%s%s", $str, $_;
    $sign_str = md5_hex($sign_str);
    {
      use bigint;
      $sign_str = hex($sign_str);
      $sign_str = $sign_str % $c->filter_size;
      push @signs, $sign_str; #$sign_str->numify;
      no bigint;
    }
  } (0 .. $c->sign_size);

  return \@signs;
}


1;
