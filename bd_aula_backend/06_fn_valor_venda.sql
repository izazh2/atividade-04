USE bd_aula_backend;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_valor_venda$$

-- 6) Calcula o valor de venda a partir do preço e do código preço:
--    código 1 => +4%  |  código 2 => +8%  |  código 3 => +10%
CREATE FUNCTION fn_valor_venda(p_preco DECIMAL(10,2), p_codigo_preco INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_percentual DECIMAL(5,2);

    -- Define o acréscimo conforme o código preço (outro código: sem acréscimo)
    SET v_percentual = CASE p_codigo_preco
        WHEN 1 THEN 0.04
        WHEN 2 THEN 0.08
        WHEN 3 THEN 0.10
        ELSE 0
    END;

    -- Preço + acréscimo, com 2 casas decimais
    RETURN ROUND(p_preco * (1 + v_percentual), 2);
END$$

DELIMITER ;

-- Teste: deve retornar 108.00
-- SELECT fn_valor_venda(100.00, 2);
