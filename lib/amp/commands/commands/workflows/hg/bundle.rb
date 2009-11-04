command :bundle do |c|
  c.workflow :hg
  
  c.desc "Create a changegroup file"
  c.help <<-EOS
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
EOS

  c.opt :force, "Run even when remote repository is unrelated",     :short => '-f'
  c.opt :rev,   "A changeset up to which you would like to bundle", :short => '-r', :type => :string
  c.opt :base,  "A base changeset to specify instead of a destination",             :type => :string
  c.opt :all,   "Bundle all changesets in the repository",          :short => '-a'
  c.opt :type,  "Bundle compression type to use (default: bzip2)",  :short => '-t'
  c.opt :ssh,   "Specify ssh command to use",                       :short => '-e', :type => :string
  c.opt :"remote-cmd", "Specify hg command to run on the remote side",              :type => :string
  
  c.on_run do |opts, args|
    repo = opts[:repository]
    puts opts[:rev].inspect # KILLME
  end  # end on_run
end