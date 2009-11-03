module Amp
  
  module CommandSupport
    # When a user specifies a range, REV_SEP is between the given revisions. 
    REV_SEP = ":"
    
    ##
    # Looks up the node ID of a given revision in the repository. Since this method uses
    # Repository#lookup, the choices for "value" are very flexible. You can choose a
    # revision number, a partial node ID, "tip", and so on. See LocalRepository#lookup
    # for more details.
    #
    # @see {LocalRepository#lookup}
    # @param [Repository] repo the repository in which to lookup the node
    # @param [String, Integer] value the search term for the node - could be a revision
    #   index #, a partial node ID, and so on
    # @param [String, Integer] default the default search term, in case +value+ is nil.
    # @return [String] the full node ID of the node that is found, or +nil+ if none is found.
    def revision_lookup(repo, value, default = nil)
      value ||= default
      repo.lookup(value)
    end
    
    ##
    # Prints the statistics returned from an update or merge. These are given in the form
    # of a hash, such as {:added => 0, :unresolved => 3, ...}, and should be printed
    # in a nice manner.
    #
    # @param [Hash<Symbol => Fixnum>] stats the statistics resulting from an update, merge
    #   or clean command.
    def print_update_stats(stats)
      Amp::UI.status stats.map {|note, files| "#{files.size} files #{note}" }.join(", ")
    end
      
    ##
    # Parses strings that represent a range of 
    # 
    # @example
    #      revision_pair(repo, ["10:tip"])     #=> [repo.lookup(10), repo.lookup("tip")]
    #      revision_pair(repo, ["10", "tip"])  #=> [repo.lookup(10), repo.lookup("tip")]
    #      revision_pair(repo, ":tip")         #=> [repo.lookup(0),  repo.lookup("tip")]
    # @param [Repository] repo the repository to use when looking up revisions
    # @param [Array, String] revisions the revisions to parse. Could be a set of strings,
    #   passed directly in from the command line, or could just be 1 string.
    # @return [Array<String>] the node IDs that correspond to the start and end of the
    #   specified range of changesets
    def revision_pair(repo, revisions)
      #revisions = [revisions] unless revisions.is_a?(Array)
      if !revisions || revisions.empty?
        return repo.dirstate.parents.first, nil
      end
      stop = nil
      
      if revisions.size == 1
        #old revision compared with working dir?
        if revisions[0].include? REV_SEP
          start, stop = revisions.first.split REV_SEP, 2
          start = revision_lookup repo, start, 0
          stop  = revision_lookup repo, stop, repo.size - 1
        else
          start = revision_lookup repo, revisions.first
        end
      elsif revisions.size == 2
        if revisions.first.include?(REV_SEP) ||
           revisions.second.include?(REV_SEP)
           raise ArgumentError.new("too many revisions specified")
        end
        start = revision_lookup(repo, revisions.first)
        stop  = revision_lookup(repo, revisions.second)
      else
        raise ArgumentError.new("too many revisions specified")
      end
      [start, stop]
    end
    
  end
end