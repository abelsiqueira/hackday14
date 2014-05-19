#!/usr/bin/env ruby

require 'csv'

csv = []
CSV.parse(File.read('db.csv'), :headers=>true).each { |row|
  csv << row.to_hash
}

puts "index,autorTopicOne,autor,enfase,uf,partido,url,foto,email,id,rotulo".split(',').map{|a|
  "\"#{a}\"" }.join(',')

i = 1

partidos = csv.inject([]) { |p,row| p << row['partido_atual'] }.compact.uniq

hist = partidos.zip([0]*partidos.length).to_h

csv.each { |row|
  hist[row['partido_atual']] += 1 if row['partido_atual']
}

csv.each { |row|

  if row['soma_liquido'].to_f < 0.01
    next
  end

  out = []
  out << "\"#{i}\""
  out << i
  i = i + 1
  out << row['nome_completo']
  out << row['soma_liquido'].to_f/hist[row['partido_atual']]
  out << row['uf']
  out << row['partido_atual']
  out << 'NA'
  out << 'NA'
  out << 'NA'
  out << row['id_deputado']
  out << row['partido_atual']
  puts out.join(',')
}

