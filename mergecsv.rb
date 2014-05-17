#!/usr/bin/env ruby

require 'csv'

if ARGV.length < 2
  raise "Needs at least two arguments"
elsif ARGV.length > 2
  raise "For now at most two arguments"
end

files = ARGV
csv = {}
files.each { |file|
  raise "File #{file} does not exists" unless File.exist?(file)

  csv[file] = []
  CSV.parse(File.read(file), :headers=>true).each { |row|
    csv[file] << row.to_hash
  }
}

db = []
csv[files[0]].zip(csv[files[1]]).each { |row1,row2|
  db << row1.merge(row2) { |k,v1,v2|
    if v1.to_s == v2.to_s
      v1.to_s
    else
      puts "Different values for same key: #{k}, #{v1}, #{v2}."
      raise "ERRO"
    end
  }
}

titles = db[0].keys
puts titles.join(',')
db.each { |row|
  out = []
  titles.each { |t|
    out << row[t]
  }
#  if out.join(',').split(',').length != titles.length
#    print titles.zip(out)
#    print "\n"
#    raise "ERRO"
#  end
  puts out.join(',')
}
