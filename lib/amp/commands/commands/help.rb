command :help do |c|
  c.workflow :all
  c.desc "Prints the help for the program."
  c.on_run do |options, args|
    output = ""
    
    if args.empty?
      output << %Q{
These are the following commands available:
}
      Amp::Command.all_for_workflow(options[:global_config]["amp", "workflow"], false).sort {|k1, k2| k1.to_s <=> k2.to_s}.each do |k, v| 
        output << "\t#{k.to_s.ljust(30, " ")}#{v.description}" + "\n"
      end
      
      output << %Q{
Run "amp help [command]" for more information.

}
    else
      
      unless cmd = Amp::Command.all_for_workflow(options[:global_config]["amp","workflow"])[args.first.to_sym]
        output = "The command #{args.first} was not found."
      else
        output = cmd.help.empty? ? cmd.description : cmd.help
        opts = cmd.options.map do |h|
          ['', h[:options][:short] || "\t", "--" + h[:name].to_s, h[:desc]].join("  ")
        end
        output << "\n\n" << "The following options are available:\n" << opts.join("\n") if opts.any?
        output << "\n\n" << "The options available for `amp` are also available for subcommands."
        output << "\n"   << "Run `amp --help` to see global options."
      end
      
    end
    
    Amp::UI.say output
  end
end