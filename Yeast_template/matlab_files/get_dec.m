function dec = get_dec(num, pos)

shift = @(i) 10 ^ (pos - i);

dec = shift(0) * (floor(shift(0) * num) / floor(shift(0)) - floor(shift(1) * num) / shift(1));