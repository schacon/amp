# I have seen few files so poorly organized such as patch.py
# What. The. Fuck. This is going to take so long to make.
module Amp
  module Patch
    
    class PatchError < StandardError; end
    class NoHunkError < PatchError; end
    
    class Patch
      
      ##
      # The filename of the patch
      attr_accessor :file_name
      
      ##
      # The opener used to open the patch
      attr_accessor :opener
      
      ##
      # @todo - add comment
      attr_accessor :lines
      
      ##
      # does the patch exist? @todo - make this accurate
      attr_accessor :exists
      
      ##
      # Is the file in the filesystem
      attr_accessor :missing
      
      ##
      # @todo - add comment
      attr_accessor :hash
      
      ##
      # Is this dirty and does it need to be resynced with something?
      attr_accessor :dirty
      alias_method  :dirty?, :dirty
      
      ##
      # @todo - add comment
      attr_accessor :offset
      
      ##
      # has this been printed? (duh)
      attr_accessor :printed
      alias_method  :printed?, :printed
      
      ##
      # @todo - add comment
      attr_accessor :hunks
      
      def initialize(file_name, opener, missing=false)
        @file_name = file_name
        @opener    = opener
        @lines     = []
        @exists    = false
        
        ##
        # If the patch is in the filesystem
        # then we should read it and accurately set its existence
        unless @missing = missing
          begin
            readlines!
            @exists = true
          rescue IOError
          end
        else
          UI::warn "unable to find '#{@file_name}' for patching"
        end
        
        @hash     = {}
        @dirty    = false
        @offset   = 0
        @rejected = []
        @printed  = false
        @hunks    = 0
      end
      
      ##
      # Loads up the patch info from +@file_name+
      # into +@lines+
      def readlines!
        @opener.open @file_name do |f|
          @lines = f.readlines
        end
      end
      
      ##
      # Write +linez+ to +fname+ as a patch.
      # 
      # @param [String] fname the filename to write to
      # @param [Array<String>] linez an array of the lines to write
      def writelines!(fname, linez)
        @opener.open fname, 'w' do |f|
          f.write linez.join("\n")
        end
      end
      
      ##
      # Mysteriously and safely disappear...
      #
      # @return [Boolean] success marker
      def unlink; File.safe_unlink @file_name; end
      
      ##
      # Print out the patch to STDOUT, or STDERR if +warn+ is true.
      # 
      # @param [Boolean] warn should we be printing to STDERR?
      def print(warn=false)
        return if printed? # no need to print it twice
        
        @printed = true if warn
        message  = "patching file #{@file_name}"
        warn ? UI::warn message : UI::note message
      end
      
      ##
      # From the Python: looks through the hash and finds candidate lines. The
      # result is a list of line numbers sorted based on distance from linenum.
      # 
      # I wish I knew how to make sense of that sentence.
      # 
      # @todo Look into removing an unnecessary `- number`.
      # @param  [String] line
      # @param  [Integer] number the line number
      # @return [Array] the lines that matchish.
      def find_lines(line, number)
        return [] unless @hash.include? line
        
        # really, we're just getting the lines and sorting them
        # is the `- number` even necessary?
        @hash[line].sort {|a, b| (a - number).abs <=> (b - number).abs }
      end
      
      ##
      # I have no clue what song I am listening to but it is SOOOOO GOOD!!!!!!!!
      # "This time baby, I'll be bullet proof"
      # If I had working internet now, I'd be googling the lyrics.
      # 
      # Oh right, the method. I don't know what this does... YET
      # 
      # @todo Figure out what this does
      def hash_lines
        @hash = Hash.new {|h, k| h[k] = [] }
        (0 ... @lines.size).each do |x|
          s = @lines[x]
          @hash[s] << x
        end
      end
      
      ##
      # our rejects are a little different from patch(1).  This always
      # creates rejects in the same form as the original patch.  A file
      # header is inserted so that you can run the reject through patch again
      # without having to type the filename.
      def write_rejects
        return if @rejects.empty?
        fname = @file_name + '.rej'
        
        UI::warn("#{@rejects.size} out of #{@hunks} hunks FAILED --" +
                 "saving rejects to file #{fname}")
        
        # i have never written code as horrid as this
        # please help me
        lz = []
        base = File.dirname @file_name
        lz << "--- #{base}\n+++ #{base}\n"
        @rejects.each do |r|
          r.hunk.each do |l|
            lz << l
            lz << "\n\ No newline at end of file\n" if l.last != "\n"
          end
        end
        
        write_lines fname, lz
      end
      
    end
    
    class PatchMeta
    end
    
    class Hunk
    end
    
    class GitHunk
    end
    
    class BinaryHunk
    end
    
    class SymLinkHunk
    end
    
    class LineReader
    end
    
  end
end