#!/usr/bin/env ruby

require 'csv'

csv = []
CSV.parse(File.read('db.csv'), :headers=>true).each { |row|
  csv << row.to_hash
}

puts "index,autorTopicOne,autor,enfase,uf,partido,url,foto,email,id,rotulo".split(',').map{|a|
  "\"#{a}\"" }.join(',')

i = 1
csv.each { |row|
  out = []
  out << "\"#{i}\""
  out << i
  i = i + 1
  out << row['nome_completo']
  out << row['soma_liquido'].to_f/1e9
  out << row['uf']
  out << row['partido_atual']
  out << 'NA'
  out << 'NA'
  out << 'NA'
  out << row['id_deputado']
  out << row['nome_completo']
  puts out.join(',')
}

