#!/usr/bin/ruby
# Updates origin git repository, branch design.
# You mast give some paths, where changes are allowed.

unless ARGV[0]
  print "\nNo directory given to sync.\n";exit 1
end

class GitDirSync
  attr_reader :work_dir
  attr_reader :changes

  def initialize(work_dirs)
    @work_dirs=work_dirs.split(',')
  end

  def dirs_string
    @work_dirs.join(', ')    
  end

  def git_status
    @changes=exec_git_command("status --porcelain")
  end

  def exec_git_command(command_string)
    `git #{command_string}`
  end

  # grep svn status. Status returns lines in kind "?   foo.bar\n! foobar.rb\n"
  # wont be used anymore
  def stat_grep(changes,sign)
    changes_lines=changes.split("\n")
    changes_lines.collect{|line|
      split=line.split
      split[1] if split[0] == sign
    }.compact
  end

  def add_files
    exec_git_command("add -A #{@work_dirs.join(" ")}") unless @work_dirs.empty?
  end

  def merge
    exec_git_command("merge -Xours")
  end

  def commit_changes
    exec_git_command("commit --message 'new design' ")
  end

  def pull_changes
    exec_git_command("pull -Xours origin design:deploy")
  end

  def push_changes
    exec_git_command("push origin deploy:design")
  end

end





sync=GitDirSync.new(ARGV[0])
print "Synchronize changes in directories '#{sync.dirs_string}' with Git ..\n"
sync.add_files
sync.git_status
print "Changes:\n#{sync.changes}\n"
sync.pull_changes
sync.commit_changes
sync.push_changes
print "Directories '#{sync.dirs_string}' synchronised\n"




