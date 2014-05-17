#!/usr/bin/ruby

require 'mysql'

data = {
  'deputados'=>{:fields=>['id_deputado', 'nome_completo', 'sexo', 'uf',
                          'partido_atual', 'profissao', 'eleicao_ocupacao',
                          'eleicao_grau_instrucao', 'eleicao_partido',
                          'situacao', 'data_nascimento', 'data_falecimento'],
                          :opts=>"id_deputado >= 0"},
}

relations = {
  :profissao=>{:table=>'profissoes',
               :read=>'profissao',
               :from=>'id_profissao',
               :return=>'nome_profissao'},
  :eleicao_ocupacao=>{:table=>'profissoes',
               :read=>'id_profissao',
               :return=>'nome_profissao'},
  'profissoes'=>{['id_profissao', 'nome_profissao']},
  'partidos'=>{:fields=>['id_partido', 'nome_partido']},
  'deputados_legislaturas'=>{:fields=>['id_deputado', 'ano_inicio']},
  'deputados_partidos'=>{:fields=>['id_deputado', 'data_saida']},
  'despesas_cota'=>{:fields=>['id_centro_custo', 'valor_documento',
                              'valor_glosa', 'valor_liquido']},
  'centros_custos'=>{:fields=>['id_centro_custo', 'id_deputado'],
                     :opts=>"id_deputado IS NOT NULL"},
  'graus_instrucao'=>{:fields=>['id_grau', 'descricao']}


basic_cols = ['id_deputado', 'nome_completo', 'sexo', 'uf',
      'partido_atual', 'profissao', 'eleicao_ocupacao',
      'eleicao_grau_instrucao', 'eleicao_partido', 'situacao']
special_cols = ['idade', 'vivo', 'ano_inicio', 'data_saida_partido',
      'despesas_documento', 'despesas_glosa', 'despesas_liquido']

begin
  puts "Connecting..."
  con = Mysql.new('143.106.45.187', 'hackday', 'hackday', 'dadosabertos', 2306)
  puts "Obtaining deputados"
  deputados = con.query "SELECT " + data['deputados'].join(',') +
      " FROM deputados WHERE id_deputado >= 0"

  #gastos = con.query "SELECT 

  File.open('db.csv','w') { |file|
    file.puts (basic_cols + special_cols).join(',')
    deputados.each_hash { |dep|
      id = dep['id_resultado']
      thisrow = {}
      basic_cols.each { |col|
        thisrow[col] = dep[col]
      }
      thisrow['idade'] = 0 #AQUIAQUIAQUIAIQAIUQAUIQAAIUQU
      thisrow['vivo'] = true #AQUIAQUIAQUIAIQAIUQAUIQAAIUQU
      thisrow['profissao'] = (con.query "SELECT nome_profissao FROM profissoes WHERE id_profissao = #{dep['profissao']}").fetch_row
      thisrow['eleicao_ocupacao'] = (con.query "SELECT nome_profissao FROM profissoes WHERE id_profissao = #{dep['eleicao_ocupacao']}").fetch_row
      thisrow['eleicao_grau_instrucao'] = (con.query "SELECT descricao FROM graus_instrucao WHERE id_grau = #{dep['eleicao_grau_instrucao']}").fetch_row

      thisrow['ano_inicio'] = (con.query "SELECT ano_inicio FROM deputados_legislaturas WHERE id_deputado = #{id}").fetch_row
      thisrow['data_saida'] = (con.query "SELECT data_saida FROM deputados_partidos WHERE id_deputado = #{id}").fetch_row
    }
  }
rescue Mysql::Error => e
  puts e
ensure
  con.close if con
end
puts "Connection closed."

