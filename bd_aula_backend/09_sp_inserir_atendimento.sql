USE bd_aula_backend;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_inserir_atendimento$$

-- 9) Insere um atendimento para uma pessoa (pelo id) e seus itens.
-- p_itens é um array JSON; as chaves têm o nome dos campos de atendimentoitem:
-- [{"iditem":1,"idfuncionario":7,"quantidade_itens":2,"valorunitario_entrada":93.60}]
-- Se a trigger da questão 10 barrar (estoque insuficiente), nada é gravado.
CREATE PROCEDURE sp_inserir_atendimento(
    IN p_idpessoa INT,
    IN p_itens JSON
)
BEGIN
    DECLARE v_idatendimento INT;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_i INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Exige pelo menos 1 item
    IF p_itens IS NULL OR JSON_TYPE(p_itens) <> 'ARRAY' OR JSON_LENGTH(p_itens) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Informe pelo menos um item em um array JSON.';
    END IF;

    START TRANSACTION;

    -- Cria o atendimento para a pessoa informada
    INSERT INTO atendimento (idpessoa, data_atendimento, status_atendimento)
    VALUES (p_idpessoa, CURDATE(), 'A');

    -- Captura o id do atendimento criado
    SET v_idatendimento = LAST_INSERT_ID();

    -- Quantos itens vieram no array
    SET v_total = JSON_LENGTH(p_itens);

    -- Percorre o array: posição 0, 1, 2...
    WHILE v_i < v_total DO
        INSERT INTO atendimentoitem
            (idatendimento, iditem, idfuncionario, quantidade_itens, valorunitario_entrada)
        VALUES (
            v_idatendimento,
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].iditem'))) AS UNSIGNED),
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].idfuncionario'))) AS UNSIGNED),
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].quantidade_itens'))) AS UNSIGNED),
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_i, '].valorunitario_entrada'))) AS DECIMAL(10,2))
        );

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT v_idatendimento AS idatendimento;
END$$

DELIMITER ;

-- Teste (ajuste os ids para os que existem no seu banco):
-- CALL sp_inserir_atendimento(1, '[{"iditem":1,"idfuncionario":7,"quantidade_itens":2,"valorunitario_entrada":93.60}]');
