module Amp
  module Repositories
    ##
    # This module adds verification to Mercurial repositories.
    #
    # The main public method provided is #verify. The rest are support methods that
    # will keep to themselves.
    #
    # This is directly ported from verify.py from the Mercurial source. This is for
    # the simple reason that, because we are re-implementing Mercurial, we should
    # rely on their verification over our own. If we discover bugs in their
    # verification, we'll patch them and send in the patches to selenic, but for now, we'll
    # trust that theirs is on the money.
    module Verification
      
      ##
      # Runs a verification sweep on the repository.
      #
      # @return [VerificationResult] the results of the verification, which
      #   includes error messages, warning counts, and so on.
      def verify
        result = Verifier.new(self).verify
      end
      
      ##
      # Handles all logic for verifying a single repository and collecting the results.
      #
      # Public interface: initialize with a repository and run #verify.
      class Verifier
        attr_accessor :repository
        alias_method :repo, :repository
        
        ##
        # Creates a new Verifier. The Verifier can verify a Mercurial repository.
        # 
        # @param [Repository] repo the repository this verifier will examine
        def initialize(repo)
          @repository = repo
          @result = VerificationResult.new
          
          @bad_revisions = {}
          @revisions = 0
          @changelog = repo.changelog
          @manifest  = repo.manifest
        end
        
        ##
        # Runs a verification sweep on the repository this verifier is handling.
        #
        # @return [VerificationResult] the results of the verification, which
        #   includes error messages, warning counts, and so on.
        def verify
          
        end
        
        ##
        # Checks a revlog for inconsistencies with the main format, such as
        # having trailing bytes or incorrect formats
        #
        # @param [Revlog] log the log we will be verifying
        # @param [String] name the name of the file this log is stored in
        def check_revlog(log, name)
          if log.empty? && (@changelog.any? || @revlog.any?)
            return error(0, "#{name} is empty or missing")
          end
          
          size_diffs = log.checksize
          # checksize returns a hash with these keys: index_diff, data_diff
          if size_diffs[:data_diff] != 0
            error(nil, "data size off by #{size_diffs[:data_diff]} bytes", name) 
          end
          if size_diffs[:index_diff] != 0
            error(nil, "index contains #{size_diffs[:index_diff] bytes}", name)
          end
          
          v0 = RevlogSupport::Support::REVLOG_VERSION_0
          if revlog.version != v0
            warn("#{name} uses revlog format 1. changelog uses format 0.") unless changelog.version == v0
          elsif changelog.version == v0
            warn("#{name} uses revlog format 0. that's really old.")
          end
        end
        
        ##
        # Checks a single entry in a revision log for inconsistencies.
        #
        # @param [Revlog] log the revision log we're examining
        # @param [Fixnum] revision the index # of the revision being examined
        # @param [String] node the node ID of the revision being examined
        # @param [Hash] seen the list of node IDs we've already seen
        # @param [Array] ok_link_revisions the acceptable link revisions for the given entry
        # @param [String] filename the name of the file containing the revlog
        def check_entry(log, revision, node, seen, ok_link_revisions, filename)
          link_rev = log.link_revision_for_index log.revision_index_for_node(node)
          # is the link_revision invalid?
          if link_rev < 0 || (changelog.empty? && ! ok_link_revisions.include?(link_rev))
            problem = (link_rev < 0 || link_rev >= changelog.size) ? "nonexistent" : "unexpected"
            error(nil, "revision #{revision} points to #{problem} changeset #{link_rev}", filename)
            
            if ok_link_revisions.any?
              warn("(expected #{ok_link_revisions.join(" ")})")
            end
            link_rev = nil # don't use this link_revision, because it's clearly wrong.
          end
          
          begin
            log.parents_for_node(node).each do |parent|
              if !seen[parent] && parent != NULL_ID
                error(link_rev, "unknown parent #{parent.short_hex} of #{node.short_hex}", filename)
              end
            end
          rescue StandardError => e 
            # TODO: do real exception handling
            error(link_rev, "error \"#{e.to_s}\" checking parents of #{node.short_hex}\n", filename)
          end
          
          if seen[node]
            error(link_rev, "duplicate revision #{revision} (#{seen[node]})", filename)
          end
          seen[node] = revision
          return link_rev
        end
        
        ##
        # Produce an error that looks like Mercurial's
        # meh compatibility makes me sad
        #
        # @param [Fixnum] revision the link-revision the error is associated with
        # @param [String, #to_s] message the message to print with the error
        # @param [String, #to_s] filename (nil) the name of the file with an error.
        #     nil for changelog/manifest
        def error(revision, message, filename = nil)
          if revision
            @bad_revisions[li] = true
          else
            revision = "?"
          end
          new_message = "#{revision}: #{message}"
          new_message = "#{filename}@#{new_message}" if filename
          
          @result.errors << new_message
        end
        
        ##
        # Adds a warning to the results
        #
        # @param [String, #to_s] message the user's warning
        def warn(message)
          @result.warnings << "warning: #{message}"
        end
      end
      
      ##
      # Simple struct that handles the results of a verification.
      class VerificationResult < Struct.new(:warnings, :errors)
        def initialize
          @warnings = []
          @errors = []
        end
      end
      
    end
  end
end