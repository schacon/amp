module Amp
  module Repositories
    class RepoError < StandardError; end
    
    # make this git-hg-svn-cvs-whatever friendly!
    def self.pick(config, path='', create=false)
      # # Determine the repository format.
      # 
      # # This hash is formatted like:
      # # {telltale_file_or_directory => AssociatedModule}
      # mod = {'.hg' => Mercurial}.detect do |telltale, _|
      #   File.exist? File.join(path, telltale)
      # end.last # because Hash#detect returns [k, v]
      # 
      # # Raise hell if we can't get a format
      # raise "Unknown Repository Format for #{path.inspect}" unless mod
      # 
      # # Now we create the appropriate local repository
      # mod::Picker.pick config, path, create
      Mercurial::Picker.pick config, path, create # cheat KILLME
    end # def self.pick
    
  end # module Repositories
  
  ##
  # This class contains the functionality of all repositories ever.
  # Methods here rely on certain base methods that are unimplemented,
  # left as an exercise for the reader.
  class AbstractRepository
    class AbstractLocalRepository
      ##
      # Returns the staging area for the repository, which provides the ability to add/remove
      # files in the next commit.
      # Returns a subclass of AbstractStagingArea
      def staging_area()
      
      ##
      # Creates a local changeset.
      # Returns boolean for success/failure
      def commit(options = {})
      
      ##
      # Pushes changesets to a remote repository.
      # Returns boolean for success/failure
      def push(options = {})
      
      ##
      # Pulls changesets from a remote repository 
      # Does *not* apply them to the working directory.
      # Returns boolean for success/failure
      def pull(options = {})
      
      ##
      # Returns a changeset for the given revision.
      # Must support at least integer indexing as well as a string "node ID", if the repository
      # system has such IDs. Also "tip" should return the tip of the revision tree.
      # Returns an AbstractChangeset
      def [](revision)
      
      ##
      # Returns the number of changesets in the repository.
      # Returns Integer
      def size
      
      ##
      # Gets a given file at the given revision, in the form of an AbstractVersionedFile object.
      # Returns AbstractVersionedFile
      def get_file(file, revision)
      
      ##
      # In whatever conflict-resolution system your repository format defines, mark a given file
      # as in conflict. If your format does not manage conflict resolution, re-define this method as
      # a no-op.
      # Returns boolean
      def mark_conflicted(*filenames)
      
      ##
      # In whatever conflict-resolution system your repository format defines, mark a given file
      # as no longer in conflict (resolved). If your format does not manage conflict resolution,
      # re-define this method as a no-op.
      # Returns boolean
      def mark_resolved(*filenames)
    end
    
  end
  
end # module Amp