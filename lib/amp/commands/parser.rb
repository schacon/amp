class AmpParser < Trollop::Parser
  # add stuff to print Amp::Command#desc
  # print options after desc, etc., NOT before (fix `amp [COMMAND] --help`)
end