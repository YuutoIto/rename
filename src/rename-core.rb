require './utils'

def recursive_rename!(path_pairs)
  unless safe_rename_pairs!(path_pairs)
    warn "Overlap: The following files did not rename, because already exists"
    overlap.each {|old, new| puts "#{old} => #{new}" }
    return false
  end

  return path_pairs.size == 0 || recursive_rename!(path_pairs)
end
