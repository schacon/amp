require 'yard'
require 'pp'


# YARD support
# yard is our documentation tool


# so that we can sort them
class YARD::CodeObjects::MethodObject
  def <=>(other)
    self.path <=> other.path
  end
end

class YARD::Tags::Library
  
  ##
  # Adds the ability to 'tag' methods.
  #   
  # For instance, you can search through all the
  # methods tagged with 'permissions' and see what
  # needs to be changed when you change your permission
  # style.
  # 
  # @param [String] text the text following the '@tags', which contains
  #   which tags the method should belong to
  def tags_tag(text)
    # long version neeeded because active_support is greedy
    YARD::Tags::DefaultFactory.new.parse_tag "tags", text.split(/,\s*/)
  end
  
end

namespace :yard do
  
  desc 'Force a rebuild of the documentation'
  task :full_doc do
    text_files = ["SCHEDULE.markdown", "AUTHORS", "STYLE", "TODO.markdown", "LICENSE"]
    options    = ["--private", "--protected", "-q", "-r README.md"]
    ruby_files = ["lib/**/**/**/*.rb", "lib/**/**/*.rb", "lib/**/*.rb", "lib/*.rb"]
    sh "yardoc #{options.join(" ")} #{ruby_files.join(" ")} - #{text_files.join(" ")}"
  end
    
  YARD::Rake::YardocTask.new :doc do |yard|
    yard.options = ['--no-output', '--private', '--protected', '--use-cache']
  end
    
  
  def docd_method_percent(klass)
    total  = klass.meths.size.to_f
    undocd = klass.meths.select {|m| m.docstring.empty? }.size.to_f
    
    undocd.zero? ? 0.0 : (undocd / total)
  end
  
  # rake yard:search[ranks]
  desc 'Search the methods for the specified tag'
  task :search => [ :doc ]
  task :search, :tag do |task, args|
    tag = args[:tag]
    methods = YARD::Registry.all(:method)
    
    meths = methods.select do |m|
      m.tags.any? {|t| t.text.include? tag }
    end
    
    puts meths.sort
  end
  
  
  desc 'Find undocumented methods'
  task :undocd => [ :doc ] do
    methods = YARD::Registry.all(:method)
    
    meths = methods.select {|m| m.docstring.empty? }
    puts meths.sort
  end
  
  
  desc 'Find untagged methods'
  task :untagged => [ :doc ] do
    methods = YARD::Registry.all(:method)
    
    meths = methods.select {|m| m.tags.empty? }
    puts meths.sort
  end
  
  desc 'Put the list of methods and their parameters.'
  task :undocd_params => [ :doc ] do
    methods = YARD::Registry.all(:method)
    missing_params = []
    methods.each do |meth|
      meth.parameters.each do |name, default|
        next if name.to_s =~ /options/ #@options will remove the param for it
        found = false
        meth.tags.each do |tag|
          if tag.tag_name.to_s == "param" && tag.name.to_s == name.to_s
            found = true
            break
          end
        end
        missing_params << meth.path+" argument: #{name}" unless found
      end
    end
    puts missing_params.inspect
  end
  
  desc 'Find the classes with the highest percent on documented methods'
  task :percent_undocd => [ :doc ] do
    klasses = YARD::Registry.all(:class)
    
    ks     = klasses.map {|k| [k, docd_method_percent(k)] }
    #pp ks
    sorted = ks.sort {|(_, percent), (_, percent2)| percent <=> percent2 }
    sorted.each do |(k, p)|
      print k, ' => ', p * 100, '%', "\n" unless p == 0.0
    end
  end
  
  
end