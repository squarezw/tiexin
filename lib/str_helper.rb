class String
  def right_padding(ch, l)
    s = ch*l + self
    s[-l, s.length]
  end
end

puts '10'.right_padding('0', 8)