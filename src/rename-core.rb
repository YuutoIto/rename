require './utils'

def safe_rename!(path_pairs)
  path_pairs.reject! do |old, new| #if elements is not deleted return nil.
    next !File.exists?(new) && File.rename(old, new)
  end
end

def recursive_rename!(path_pairs)
  unless safe_rename!(path_pairs)
    warn "Overlap: The following files did not rename, because already exists"
    overlap.each {|old, new| puts "#{old} => #{new}" }
    return false
  end

  return path_pairs.size == 0 || recursive_rename!(path_pairs)
end
