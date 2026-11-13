USE bd_aula_backend;

-- Usa a função fn_valor_venda (questão 6): rode o script 06 antes de inserir entradas.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_entrada_produto_ai$$

-- 8) Depois de inserir uma entrada de produto:
--    - o valor unitário de entrada vira o novo preço do item (e muda o preço de venda)
--    - a quantidade de entrada é somada ao estoque
CREATE TRIGGER trg_entrada_produto_ai
AFTER INSERT ON entrada_produto
FOR EACH ROW
BEGIN
    -- Novo preço do item = valor unitário de entrada
    UPDATE item
       SET preco = NEW.valor_unitario_entrada
     WHERE iditem = NEW.iditem;

    -- Recalcula o preço de venda com a função, usando o código preço do produto
    UPDATE produto
       SET preco_venda = fn_valor_venda(NEW.valor_unitario_entrada, codigo_preco)
     WHERE iditem = NEW.iditem;

    -- Estoque atual + quantidade que entrou
    UPDATE estoque
       SET quantidade_estoque = quantidade_estoque + NEW.quantidade_entrada
     WHERE iditem = NEW.iditem;
END$$

DELIMITER ;

-- Teste:
-- INSERT INTO entrada_produto (iditem, data_entrada_produto, quantidade_entrada, unidade, valor_unitario_entrada)
-- VALUES (1, CURDATE(), 20, 'UN', 90.00);
