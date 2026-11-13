USE bd_aula_backend;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_produto_ai_estoque$$

-- 7) Depois de inserir um produto, cria o registro dele em estoque com quantidade 0.
-- (No modelo, a chave do produto é iditem.)
CREATE TRIGGER trg_produto_ai_estoque
AFTER INSERT ON produto
FOR EACH ROW
BEGIN
    -- NEW.iditem é o id do produto que acabou de ser inserido
    INSERT INTO estoque (iditem, quantidade_estoque)
    VALUES (NEW.iditem, 0);
END$$

DELIMITER ;
