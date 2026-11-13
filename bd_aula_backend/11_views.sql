USE bd_aula_backend;

-- 11) Views (no enunciado, a numeração repete o 10)

-- Clientes (quem não é funcionário) e seus endereços
CREATE OR REPLACE VIEW vw_clientes_enderecos AS
SELECT p.idpessoa, p.nome, p.cpf, p.email, p.telefone,
       e.idendereco, e.cep, e.numero, e.complemento
FROM pessoa p
LEFT JOIN endereco e ON e.idpessoa = p.idpessoa
WHERE NOT EXISTS (SELECT 1 FROM funcionario f WHERE f.idpessoa = p.idpessoa);

-- Funcionários e seus endereços
CREATE OR REPLACE VIEW vw_funcionarios_enderecos AS
SELECT p.idpessoa, p.nome, p.cpf, f.cargo, f.data_admissao,
       e.idendereco, e.cep, e.numero, e.complemento
FROM funcionario f
INNER JOIN pessoa p ON p.idpessoa = f.idpessoa
LEFT JOIN endereco e ON e.idpessoa = p.idpessoa;

-- Serviços (tipo 'S') e suas categorias
CREATE OR REPLACE VIEW vw_servicos_categorias AS
SELECT i.iditem, i.item AS servico, i.descricao_item, i.preco,
       c.idcategoria, c.categoria
FROM item i
INNER JOIN categoria c ON c.idcategoria = i.idcategoria
WHERE i.tipo_item = 'S';

-- Produtos, categorias e quantidade em estoque
CREATE OR REPLACE VIEW vw_produtos_estoque AS
SELECT i.iditem, i.item AS produto, c.categoria,
       pr.preco_venda, pr.unidade, es.quantidade_estoque
FROM produto pr
INNER JOIN item i ON i.iditem = pr.iditem
INNER JOIN categoria c ON c.idcategoria = i.idcategoria
INNER JOIN estoque es ON es.iditem = pr.iditem;

-- Atendimentos: cliente, itens, quantidades, valores e funcionário que atendeu
CREATE OR REPLACE VIEW vw_atendimentos AS
SELECT a.idatendimento, a.data_atendimento, a.status_atendimento,
       cli.nome AS cliente,
       i.item, ai.quantidade_itens, ai.valorunitario_entrada,
       (ai.quantidade_itens * ai.valorunitario_entrada) AS valor_total,
       fun.nome AS funcionario
FROM atendimento a
INNER JOIN pessoa cli ON cli.idpessoa = a.idpessoa
INNER JOIN atendimentoitem ai ON ai.idatendimento = a.idatendimento
INNER JOIN item i ON i.iditem = ai.iditem
INNER JOIN pessoa fun ON fun.idpessoa = ai.idfuncionario;
