#!/user/bin/env ruby

HAPPY = 0 # +
BLANK = 1 # -

def solve(stack)
  number, bits = stack_to_number(stack)
  solve_number(number, bits, 0)
end

def solve_number(number, bits, flip_count)
  if number == 0
    return flip_count
  end

  if number[0] == BLANK
    number, bits, flip_count = make_top_blank(number, bits, flip_count)
    return solve_number(*flip(bits, number, bits, flip_count))
  else
    number, bits = ignore_bottom(number, bits)
    return solve_number(number, bits, flip_count)
  end
end

def make_top_blank(number, bits, flip_count)
  happy_count = 0
  bits.times do |i|
    if number[bits-i-1] == HAPPY
      happy_count += 1
    else
      break
    end
  end
  if happy_count > 0
    flip(happy_count, number, bits, flip_count)
  else
    [number, bits, flip_count]
  end
end

def ignore_bottom(number, bits)
  happy_count = 0
  bits.times do |i|
    if number[i] == HAPPY
      happy_count += 1
    else
      break
    end
  end
  [number >> happy_count, bits - happy_count]
end

def flip(target, number, bits, flip_count)
  to_flip = (number >> (bits-target))
  bottom = (number % (2 ** (bits-target)))
  flipped = 0
  target.times do |i|
    bit = to_flip[i] ^ 1
    flipped += bit << (target-i-1)
  end
  number = [(flipped << (bits-target)) + bottom, bits, flip_count+1]
end

def stack_to_number(stack)
  number = 0
  bits = 0
  stack.split('').map{|c| c == '+' ? 0 : 1}.each do |n|
    number = (number << 1) + n
    bits += 1
  end
  [number, bits]
end

@cache = {}

begin
  # tests
  number, bits = stack_to_number('--+-')
  if [number, bits] != [0b1101, 4]
    fail '#stack_to_number failed'
  end

  number, bits, flip_count = flip(4, 0b101100, 6, 1)
  if [number, bits, flip_count] != [0b001000, 6, 2]
    fail '#flip failed'
  end

  number, bits = ignore_bottom(0b010100, 6)
  if [number, bits] != [0b0101, 4]
    fail '#ignore_bottom failed'
  end
  # number, bits = stack_to_number('++++++++++__________++++++++++__________++++++++++__________++++++++++__________++++++++++__________')
end

case_count = gets.chomp.to_i
case_count.times do |cc|
  buffer = gets.chomp
  STDERR.puts "#{cc+1}: #{Time.now}" if cc % 10 == 9
  ans = solve(buffer)

  puts "Case ##{cc+1}: #{ans}"
end
