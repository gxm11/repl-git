# encoding:utf-8

# project settings
Project = "sinatbbs"
Repository = "https://github.com/gxm11/#{Project}.git"
Command = "ruby main.rb"

puts "-" * 40
puts "Project: #{Project}"
puts "Repository: #{Repository}"
puts "Command: #{Command}"
puts "-" * 40
if File.exist?(Project)
  # 1. kill running process
  print "Stop last project..."
  begin
    pid = File.read("pid").to_i
    Process.kill(9, pid)
    puts "Done."
  rescue
    puts "skipped."
  end 
  # 2. git pull to update project code
  puts "Update project..."
  Dir.chdir(Project)
  `git pull`
  Dir.chdir("..")  
  # 3. update Gemfile, install gems
  print "Update Gemfile..."
  g0 = `md5sum Gemfile`
  g0 = g0 ? g0.split().first : 0
  g1 = `md5sum #{Project}/Gemfile`
  g1 = g1 ? g1.split().first : 0
  if g0 == g1
    puts "Skipped."
  else
    puts "Please wait..."
    `rm Gemfile.lock`
    `cp #{Project}/Gemfile .`
    `bundle install`
    puts "-" * 40
    puts "Gem is ready, please run again."
    exit()
  end
  # 4. run project in child process
  puts "Start project..."  
  Dir.chdir(Project)  
  pid = Process.spawn(Command)
  Dir.chdir("..")
  # 5. store pid in file
  IO.write("pid", pid)
  puts "-" * 40
  puts "Project is running, pid is #{pid}."  
else
  # git clone project
  puts "Clone project..."
  `git clone #{Repository} #{Project} --depth=1`
  puts "-" * 40
  puts "Project is ready, please run again."
  exit()
end

def top
  puts `top -b -n1`
end

def quit
  pid = File.read("pid").to_i
  # 2 => Ctrl-C, 9 => kill
  Process.kill(2, pid)
  exit()
end

alias q quit
puts "-" * 40
puts "Interactive mode start, try top or quit."
puts "-" * 40
loop do
  puts eval(gets.chop, binding) rescue quit
end
