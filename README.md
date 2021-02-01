* Filter

基于redis实现的布隆过滤器.
hash 算法使用 N 次 md5_hex( sprintf "%s%s", $str, $_) 0 .. n;
注意: 布隆算法, 本身是有容错率. 不是完全准确.


** 使用方法

  use Filter;
  my $filter = Filter->new( redis => $bala, redis_key => $foo, sign_size => 5 );
  my $is_exists = $filter->check('bala', $is_save_to_cache);
  #  $is_exists 值: 0 不存在,  1 存在
