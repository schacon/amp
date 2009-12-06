module Amp
  module Repositories
    class RepoError < StandardError; end
    
    # make this git-hg-svn-cvs-whatever friendly!
    def self.pick(config, path='', create=false)
      # Determine the repository format.
      
      # This hash is formatted like:
      # {telltale_file_or_directory => AssociatedModule}
      mod = {'.hg' => Mercurial}.detect do |telltale, _|
        File.exist? File.join(path, telltale)
      end.last # because Hash#detect returns [k, v]
      
      # Raise hell if we can't get a format
      raise "Unknown Repository Format for #{path.inspect}" unless mod
      
      # Now we create the appropriate local repository
      mod::Picker.pick config, path, create
    end # def self.pick
    
  end # module Repositories
  
  ##
  # This class contains the functionality of all repositories ever.
  # Methods here rely on certain base methods that are unimplemented,
  # left as an exercise for the reader.
  class AbstractRepository
  end
  
end # module Amp