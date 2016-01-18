#!/usr/bin/ruby

unless ARGV[0]
  print "\nNo directory given to sync.\n";exit 1
end

class SVNDirSync
  attr_reader :work_dir
  attr_reader :changes

  def initialize(work_dir)
    @work_dir=work_dir
  end

  def read_dir_status
    @changes=exec_svn_command("status")
  end

  def exec_svn_command(command_string)
    `cd #{@work_dir}; svn #{command_string} --non-interactive --username design`
  end

  # grep svn status. Status returns lines in kind "?   foo.bar\n! foobar.rb\n"
  def stat_grep(changes,sign)
    changes_lines=changes.split("\n")
    changes_lines.collect{|line|
      split=line.split
      split[1] if split[0] == sign
    }.compact
  end

  def add_files
    files=stat_grep(changes,"?")
    exec_svn_command("add #{files.join(" ")}") if files.size>0
  end

  def del_files
    files=stat_grep(changes, "!")
    exec_svn_command("del #{files.join(" ")}") if files.size>0
  end

  def resolve
    exec_svn_command("resolve --accept mine-full *")
  end

  def commit_dir
    exec_svn_command("commit --message 'new design' ")
  end

  def update_dir
    exec_svn_command("update")
  end

end





sync=SVNDirSync.new(ARGV[0])
print "Synchronize changes in directory '#{sync.work_dir}' with SVN ..\n"
sync.read_dir_status
sync.add_files
sync.del_files
sync.read_dir_status
print "Changes:\n#{sync.changes}\n"
sync.update_dir
sync.resolve
sync.commit_dir
print "Directory '#{sync.work_dir}' done\n"




