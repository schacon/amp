command :diff do |c|
  c.desc "Shows the differences between changesets"
  c.opt :pretty, "Makes the output pretty", :short => "-p", :default => true
  c.opt :rev, "Specifies a revision for diffing.", :short => "-r", :multi => true, :type => :integer
  c.on_run do |opts, args|
    repo = opts[:repository]
    revs = opts[:rev] || []
    
    revs << "tip" if revs.size == 0
    revs << nil   if revs.size == 1
    require 'pp'
    
    pp revs
    
    differences = repo.status(:node_1 => revs[0], :node_2 => revs[1])
    
    pp differences
  end
end