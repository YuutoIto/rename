require './utils'

# if newpath is not exists, oldpath to newpath.
# return the overlap path.
def safe_rename(path_pairs)
  overlap = []
  path_pairs.each do |old, new|
    unless File.exists(new)
      File.rename(old, new)
    else
      overlap.push([old, new])
    end
  end

  return overlap
end

# do safe_rename recursively
# if all successful return true,
# bad return false.
def recursive_rename(path_pair)
  overlap = self.safe_rename(path_pair)
  case overlap.size
  when 0
    return true
  when path_pair.size
    warn "Overlap: The following files did not rename, because already exists"
    overlap.each {|old, new| puts "#{old} => #{new}" }
    return false
  else
    return recursive_rename(overlap)
  end
end
