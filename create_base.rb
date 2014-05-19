#!/usr/bin/ruby

require 'mysql'

data = ['id_deputado', 'nome_completo', 'sexo', 'uf', 'partido_atual',
        'profissao', 'eleicao_ocupacao', 'eleicao_grau_instrucao',
        'eleicao_partido', 'situacao', 'data_nascimento', 'data_falecimento']

basic_cols = ['id_deputado', 'nome_completo', 'sexo', 'uf', 'partido_atual',
              'profissao', 'eleicao_ocupacao', 'eleicao_grau_instrucao',
              'eleicao_partido', 'situacao', 'data_nascimento',
              'data_falecimento']
special_cols = ['ano_inicio', 'data_saida', 'soma_documento', 'soma_glosa',
                'soma_liquido']

begin
  puts "Connecting..."
  con = Mysql.new('143.106.45.187', 'hackday', 'hackday', 'dadosabertos', 2306)
  puts "Obtaining deputados"
  cmd = "SELECT " + data.join(',') + " FROM deputados WHERE id_deputado >= 0"
  puts cmd
  deputados = con.query "#{cmd}"

  puts "Opening file"
  File.open('db_abel.csv','w') { |file|
    file.puts (basic_cols + special_cols).join(',')
    deputados.each_hash { |dep|
      id = dep['id_deputado']
      thisrow = {}
      basic_cols.each { |col|
        thisrow[col] = dep[col]
      }
      thisrow['eleicao_grau_instrucao'] = (con.query "SELECT descricao FROM graus_instrucao WHERE id_grau = #{dep['eleicao_grau_instrucao']}").fetch_row[0] if dep['eleicao_grau_instrucao']

      thisrow['ano_inicio'] = (con.query "SELECT ano_inicio FROM deputados_legislaturas WHERE id_deputado = #{id}").fetch_row
      thisrow['ano_inicio'] = thisrow['ano_inicio'][0] if thisrow['ano_inicio']

      thisrow['data_saida'] = (con.query "SELECT data_saida FROM deputados_partidos WHERE id_deputado = #{id}").fetch_row
      thisrow['data_saida'] = thisrow['data_saida'][0] if thisrow['data_saida']

      soma_doc = 0
      soma_glosa = 0
      soma_liq = 0
      (con.query "SELECT id_centro_custo FROM centros_custos WHERE id_deputado=#{id}").each { |cc|
        (con.query "SELECT valor_documento,valor_glosa,valor_liquido FROM despesas_cota WHERE id_centro_custo=#{cc[0]}").each { |row|
          soma_doc += row[0].to_f
          soma_glosa += row[1].to_f
          soma_liq += row[2].to_f
        }
      }
      thisrow['soma_documento'] = sprintf("%.2f", soma_doc)
      thisrow['soma_glosa'] = sprintf("%.2f", soma_glosa)
      thisrow['soma_liquido'] = sprintf("%.2f", soma_liq)

      out = []
      (basic_cols + special_cols).each { |col|
        out << thisrow[col]
      }

      if out.join(',').split(',').length != basic_cols.length + special_cols.length
        puts "Wrong number of columns"
      end
      file.puts out.join(',')
    }
  }
rescue Mysql::Error => e
  puts e
ensure
  con.close if con
end
puts "Connection closed."

