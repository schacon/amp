command :verify do |c|
  c.desc "Verifies the mercurial repository, checking for integrity errors"
  c.workflow :hg
  c.on_run do |opts, args|
    results = opts[:repository].verify
    puts "#{results.files} files, #{results.changesets} changesets, #{results.revisions} revisions"
    puts "#{results.errors} errors, #{results.warnings} warnings."
  end
end