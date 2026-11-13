USE bd_aula_backend;

-- Pensado para tabelas vazias (os ids seguem a ordem de inserção: 1, 2, 3...).
-- Rode depois de criar o banco (02), a função (06), as triggers (07, 08, 10) e as views (11).

-- categoria
INSERT INTO categoria (categoria) VALUES
('Pecas'),
('Acessorios'),
('Manutencao');

-- pessoa (ids 1 a 6 = clientes, 7 e 8 = funcionários)
INSERT INTO pessoa (nome, cpf, data_nascimento, sexo, email, telefone, ativo_pessoa) VALUES
('Joao Silva',      11122233344, '1990-05-10', 'M', 'joao.silva@email.com',      79999990001, 'S'),
('Maria Souza',     22233344455, '1985-08-22', 'F', 'maria.souza@email.com',     79999990002, 'S'),
('Pedro Oliveira',  33344455566, '1998-12-01', 'M', 'pedro.oliveira@email.com',  79999990003, 'S'),
('Ana Costa',       44455566677, '1992-03-15', 'F', 'ana.costa@email.com',       79999990004, 'S'),
('Lucas Pereira',   55566677788, '1995-11-30', 'M', 'lucas.pereira@email.com',   79999990005, 'S'),
('Fernanda Lima',   66677788899, '1988-07-19', 'F', 'fernanda.lima@email.com',   79999990006, 'S'),
('Rafael Santos',   77788899900, '1987-02-02', 'M', 'rafael.santos@email.com',   79999990007, 'S'),
('Juliana Alves',   88899900011, '1991-09-09', 'F', 'juliana.alves@email.com',   79999990008, 'S');

-- endereco (algumas pessoas com 2 endereços; complemento é NOT NULL, então vazio em vez de null)
INSERT INTO endereco (idpessoa, cep, numero, complemento) VALUES
(1, '49000000', '10',  'Casa'),
(1, '49010000', '55',  'Trabalho'),
(2, '49020000', '120', 'Apto 101'),
(3, '49030000', '8',   'Casa'),
(4, '49040000', '300', ''),
(5, '49050000', '45',  'Bloco B'),
(6, '49060000', '77',  'Casa'),
(6, '49070000', '12',  'Sitio'),
(7, '49080000', '5',   'Casa'),
(8, '49090000', '88',  'Fundos');

-- funcionario (idpessoa 7 e 8)
INSERT INTO funcionario (idpessoa, cargo, data_admissao) VALUES
(7, 'Atendente', '2024-01-15'),
(8, 'Mecanica',  '2023-06-01');

-- item: iditem 1 a 3 = produtos (tipo P), 4 e 5 = serviços (tipo S)
INSERT INTO item (idcategoria, item, descricao_item, preco, tipo_item, ativo_produto_servico) VALUES
(1, 'Pneu aro 29',    'Pneu para bicicleta aro 29',      100.00, 'P', 'S'),
(1, 'Camara de ar',   'Camara de ar aro 29',              20.00, 'P', 'S'),
(2, 'Capacete',       'Capacete adulto tamanho M',       150.00, 'P', 'S'),
(3, 'Revisao geral',  'Revisao completa da bicicleta',    80.00, 'S', 'S'),
(3, 'Troca de pneu',  'Mao de obra para troca de pneu',   20.00, 'S', 'S');

-- produto (só os itens 1 a 3)
-- A trigger da questão 7 cria o estoque de cada um com quantidade 0
INSERT INTO produto (iditem, codigo_preco, preco_venda, unidade) VALUES
(1, 1, fn_valor_venda(100.00, 1), 'UN'),
(2, 2, fn_valor_venda(20.00, 2),  'UN'),
(3, 3, fn_valor_venda(150.00, 3), 'UN');

-- entrada_produto
-- A trigger da questão 8 atualiza preço, preço de venda e soma no estoque
INSERT INTO entrada_produto (iditem, data_entrada_produto, quantidade_entrada, unidade, valor_unitario_entrada) VALUES
(1, '2026-10-01', 20, 'UN', 90.00),
(2, '2026-10-01', 50, 'UN', 15.00),
(3, '2026-10-01', 10, 'UN', 120.00);

-- atendimento (clientes 1, 2 e 3)
INSERT INTO atendimento (idpessoa, data_atendimento, status_atendimento) VALUES
(1, '2026-10-02', 'F'),
(2, '2026-10-03', 'F'),
(3, '2026-10-04', 'A');

-- atendimentoitem
-- A trigger da questão 10 valida e debita o estoque dos produtos
-- idfuncionario = 7 (Rafael) ou 8 (Juliana)
INSERT INTO atendimentoitem (idatendimento, iditem, idfuncionario, quantidade_itens, valorunitario_entrada) VALUES
(1, 1, 7, 2, 93.60),   -- 2 pneus
(1, 5, 7, 1, 20.00),   -- troca de pneu (serviço)
(2, 3, 8, 1, 132.00),  -- 1 capacete
(2, 2, 8, 3, 16.20),   -- 3 camaras de ar
(2, 4, 8, 1, 80.00),   -- revisão geral (serviço)
(3, 2, 8, 2, 16.20);   -- 2 camaras de ar

-- Conferência (estoque esperado: item 1 = 18, item 2 = 45, item 3 = 9)
SELECT * FROM pessoa;
SELECT * FROM estoque;
SELECT * FROM vw_atendimentos;

-- Teste do bloqueio (questão 10): deve dar erro "Estoque insuficiente..."
-- INSERT INTO atendimentoitem (idatendimento, iditem, idfuncionario, quantidade_itens, valorunitario_entrada)
-- VALUES (3, 3, 8, 999, 132.00);
