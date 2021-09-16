Puppet::Functions.create_function(:mysql_deepmerge) do
  def mysql_deepmerge(*args)

    if args.length < 2
      raise Puppet::ParseError, ("mysql_deepmerge(): wrong number of arguments (#{args.length}; must be at least 2)")
    end

    result = Hash.new
    args.each do |arg|
      next if arg.is_a? String and arg.empty? # empty string is synonym for puppet's undef
      # If the argument was not a hash, skip it.
      unless arg.is_a?(Hash)
        raise Puppet::ParseError, "mysql_deepmerge: unexpected argument type #{arg.class}, only expects hash arguments"
      end

      # Now we have to traverse our hash assigning our non-hash values
      # to the matching keys in our result while following our hash values
      # and repeating the process.
      overlay( result, arg )
    end
    return( result )
  end

  def has_normalized!(hash, key)
    return true if hash.has_key?( key )
    return false unless key.match(/-|_/)
    other_key = key.include?('-') ? key.gsub( '-', '_' ) : key.gsub( '_', '-' )
    return false unless hash.has_key?( other_key )
    hash[key] = hash.delete( other_key )
    return true;
  end

  def overlay( hash1, hash2 )
    hash2.each do |key, value|
      if(has_normalized!( hash1, key ) and value.is_a?(Hash) and hash1[key].is_a?(Hash))
        overlay( hash1[key], value )
      else
        hash1[key] = value
      end
    end
  end

end
