command :bundle do |c|
  c.workflow :hg
  
  c.desc "Create a changegroup file"
  c.help <<-EOS
amp bundle [options]+ file dest

  Generate a compressed changegroup file collecting changesets not
  known to be in another repository.
  
  If no destination repository is specified the destination is
  assumed to have all the nodes specified by one or more --base
  parameters. To create a bundle containing all changesets, use
  --all (or --base null). To change the compression method applied,
  use the -t option (by default, bundles are compressed using bz2).
  
  The bundle file can then be transferred using conventional means and
  applied to another repository with the unbundle or pull command.
  This is useful when direct push and pull are not available or when
  exporting an entire repository is undesirable.
  
  Applying bundles preserves all changeset contents including
  permissions, copy/rename information, and revision history.
  
  Options are:
EOS

  c.opt :force, "Run even when remote repository is unrelated",     :short => '-f'
  c.opt :rev,   "A changeset up to which you would like to bundle", :short => '-r', :type => :string
  c.opt :base,  "A base changeset to specify instead of a destination",             :type => :string
  c.opt :all,   "Bundle all changesets in the repository",          :short => '-a'
  c.opt :type,  "Bundle compression type to use (default: bzip2)",  :short => '-t',                   :default => 'bzip2'
  c.opt :ssh,   "Specify ssh command to use",                       :short => '-e', :type => :string
  c.opt :"remote-cmd", "Specify hg command to run on the remote side",              :type => :string
  
  c.on_run do |opts, args|
    repo  = opts[:repository]
    rev   = opts[:rev]
    fname = args.shift
    dest  = args.shift
    
    # returns [String, Array, String]
    parse_url = lambda do |*arr|
      url  = arr.shift
      revs = arr.shift || []
      
      unless url =~ /#/
        hds = revs.any? ? revs : []
        return url, hds, revs[-1]
      end
      
      url, branch = url.split('#')[0..1]
      checkout = revs[-1] || branch
      [url, revs + [branch], checkout]
    end
    
    # Return repository location relative to cwd or from [paths]
    expand_path = proc do |*arr|
      loc  = arr.shift
      dflt = arr.shift # dflt = default
    
      return loc if loc =~ /:\/\// or File.directory?(File.join(loc, '.hg'))
    
      path = config['paths'][loc]
    
      if !path && dflt
        path = config['paths'][dflt]
      end
      path || loc
    end
    
    # Type notation!
    # rev :: Amp::Changeset
    rev  = repo.lookup rev
    base = repo.lookup(opts[:all] ? nil : opts[:base]) # --all overrides --base
    
    if base
      if dest
        raise AbortError.new("--base is incompatible with " +
                             "specifiying a destination")
      end
      
      o   = []
      has = {Amp::RevlogSupport::Node::NULL_ID => nil}
      
      # iterates over each file node id
      base.each do |filename, node_id|
        has.update repo.changelog.reachable_nodes_for_node(node_id)
      end
      
      visit = [rev]
      seen  = {} # {node => Boolean} where node is a string
      add   = proc do |node|
        seen[node] = true
        visit << node
      end
      
      until visit.empty?
        n = visit.pop
        
        # for those who are lame:
        # rents = 'rents = parents
        rents = repo.changelog.parents(n).filter {|parental_unit| !has.include?(parental_unit) }
        
        if rents.empty?
          o.shift n
        else
          rents.each {|rent| add[ rent ] unless seen.include? rent }
        end # end if
      end # end until
    else
      path = expand_path[ dest || 'default-push', dest || 'default' ]
      dest, revs, checkout = *parse_url[ path, [rev] ]
      # alio is Esperanto for "other", and it's conveniently the same length as repo
      alio = Amp::Repositories.pick nil, dest
      o = repo.find_outgoing_roots other, :force => opts[:force]
    end # end if
    
    # Oh no, bitches! If you thought we were done, you'd be wrong.
    # Nevermind, false alarm. Turns out there's not that much left to do.
    
    revs ||= [rev]
    cg = if revs
           repo.changegroup_subset o, revs, 'bundle'
         else
           repo.changegroup o, 'bundle'
         end
    
    # these few lines convert nice human speak to icky computer speak
    bundle_type = opts[:type].downcase
    btypes      = {'none' => 'HG10UN', 'bzip2' => 'HG10BZ', 'gzip' => 'HG10GZ'}
    bundle_type = btypes[bundle_type]
    
    # some error checking
    # yes, this calls Array#include, but the array is only 3 elements
    unless Amp::RevlogSupport::ChangeGroup::BUNDLE_TYPES.include? bundle_type
      raise AbortError.new('unknown bundle type specified with --type')
    end
    
    File.open fname, 'w' do |file|
      Amp::RevlogSupport::ChangeGroup.write_bundle cg, bundle_type, file
    end
  end  # end on_run
end