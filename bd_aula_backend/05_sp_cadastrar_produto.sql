USE bd_aula_backend;

-- Esta procedure usa a função fn_valor_venda (questão 6) e a trigger da
-- questão 7 (que cria o estoque). Elas precisam existir antes de CHAMAR a procedure.

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_cadastrar_produto$$

-- 5) Cadastra um produto. Produto é um item (tipo 'P') + dados em "produto".
CREATE PROCEDURE sp_cadastrar_produto(
    IN p_idcategoria INT,
    IN p_item VARCHAR(40),
    IN p_descricao VARCHAR(200),
    IN p_preco DECIMAL(10,2),
    IN p_codigo_preco INT,
    IN p_unidade CHAR(10)
)
BEGIN
    DECLARE v_iditem INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Primeiro grava o item (dados comuns a produtos e serviços)
    INSERT INTO item (idcategoria, item, descricao_item, preco, tipo_item, ativo_produto_servico)
    VALUES (p_idcategoria, p_item, p_descricao, p_preco, 'P', 'S');

    -- Captura o iditem gerado
    SET v_iditem = LAST_INSERT_ID();

    -- Depois grava os dados específicos do produto.
    -- O preço de venda vem da função da questão 6.
    -- A trigger da questão 7 cria o estoque automaticamente (quantidade 0).
    INSERT INTO produto (iditem, codigo_preco, preco_venda, unidade)
    VALUES (v_iditem, p_codigo_preco, fn_valor_venda(p_preco, p_codigo_preco), p_unidade);

    COMMIT;

    SELECT v_iditem AS iditem;
END$$

DELIMITER ;

-- Teste:
-- CALL sp_cadastrar_produto(1, 'Pneu aro 29', 'Pneu para bike', 100.00, 2, 'UN');
