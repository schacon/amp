command :import do |c|
  c.workflow :hg
  c.desc "Import an ordered set of patches"
  
  c.on_run do |opts, args|
    repo = opts[:repository]
    
  end  # end on_run
end