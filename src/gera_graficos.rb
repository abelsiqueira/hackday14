#!/usr/bin/env ruby

require 'csv'
require 'pathname'

path = File.expand_path(File.dirname(__FILE__))
filename = path+'/../db/db.csv'

# Le todo o banco csv
csv = []
CSV.parse(File.read(filename), :headers=>true).each { |row|
  csv << row.to_hash
}

# Pega o nome dos partidos (na eleicao)
partidos = csv.inject([]) { |p,row| p << row['eleicao_partido'] }.compact.uniq
# Calcula quantas pessoas tem por partido, e jah soma o gasto
hist = partidos.zip([0]*partidos.length).to_h
gasto = partidos.zip([0.0]*partidos.length).to_h
csv.each { |row|
  next unless row['eleicao_partido']
  hist[row['eleicao_partido']] += 1 if row['eleicao_partido']
  gasto[row['eleicao_partido']] += row['soma_liquido'].to_f
}

#Soma de Gastos por partido
sgp = partidos.map{ |x|
  ["\"#{x}(#{hist[x]})\"",
   sprintf("%.2f", gasto[x]/(hist[x]*1e6))]
}.sort_by { |x|x[1].to_f}
File.open(path+'/../assets/soma-de-gastos-partidos.js','w') { |file|
  file.puts "var data = {"
  file.puts "  labels : [" + sgp.map{|x| x[0] }.join(',') + "],"
  file.puts "  datasets : [ {"
  file.puts "    fillColor : \"rgba(120,150,255,0.5)\","
  file.puts "    strokeColor : \"rgba(100,100,200,1)\","
  file.puts "    data : [" + sgp.map{|x| x[1] }.join(',') + "],"
  file.puts "}]}"
}
