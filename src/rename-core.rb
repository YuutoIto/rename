require './utils'

class TargetPathes
  def each(&block)
    @names.each{ |oldname| block.call(oldname) }
  end

  def apply_name_pair
    recursive_rename(@path_set)
  end

  def set_name_pair(&block)
    @path_set = []
    @names.each do |oldname|
      newname = block.call(oldname)
      @path_set.push([@DIR_NAME.join(oldname), @DIR_NAME.join(newname)])
    end
    return nil
  end

  def safe_rename(path_pairs)
    overlap = []
    path_pairs.each do |oldpath, newpath|
      if (!File.exists?(newpath))
        File.rename(oldpath, newpath)
      elsif (oldpath != newpath)
        overlap.push([oldpath, newpath])
      end
    end

    return overlap
  end

  def recursive_rename(path_pair)
    count   = path_pair.size
    overlap = self.safe_rename(path_pair) #renameして重複を得る

    if (overlap.size == 0)
      return true
    elsif (overlap.size <  count) #重複が減っていれば
      return self.recursive_rename(overlap)
    elsif (overlap.size == count) #重複が一つも解決しなければ
      warn "Overlap: The following files did not rename, because already exists"
      overlap.each {|old, new| puts "#{old} => #{new}" }
      return false
    end
  end
end
