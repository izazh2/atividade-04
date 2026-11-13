USE bd_aula_backend;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_cadastrar_pessoa$$

-- 3) Cadastra uma pessoa com 1 ou mais endereços.
-- Os endereços vêm em um array JSON (mesmo padrão da questão 9):
-- [{"cep":"49000000","numero":"10","complemento":"Casa"},
--  {"cep":"49010000","numero":"55","complemento":"Trabalho"}]
-- Se o CPF já existe, a pessoa é reaproveitada e os endereços são acrescentados.
CREATE PROCEDURE sp_cadastrar_pessoa(
    IN p_nome VARCHAR(100),
    IN p_cpf BIGINT,
    IN p_data_nascimento DATE,
    IN p_sexo CHAR(1),
    IN p_email VARCHAR(100),
    IN p_telefone BIGINT,
    IN p_enderecos JSON
)
BEGIN
    DECLARE v_idpessoa INT DEFAULT NULL;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_cep CHAR(8);
    DECLARE v_numero CHAR(10);
    DECLARE v_comp_json JSON;
    DECLARE v_complemento VARCHAR(150);

    -- Se qualquer comando der erro, desfaz tudo e repassa o erro
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Exige pelo menos 1 endereço
    IF p_enderecos IS NULL OR JSON_TYPE(p_enderecos) <> 'ARRAY' OR JSON_LENGTH(p_enderecos) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Informe pelo menos um endereco em um array JSON.';
    END IF;

    START TRANSACTION;

    -- Procura se já existe uma pessoa com esse CPF
    SELECT idpessoa INTO v_idpessoa
      FROM pessoa
     WHERE cpf = p_cpf
     LIMIT 1;

    -- Se não existe, cadastra a pessoa
    IF v_idpessoa IS NULL THEN
        INSERT INTO pessoa (nome, cpf, data_nascimento, sexo, email, telefone, ativo_pessoa)
        VALUES (p_nome, p_cpf, p_data_nascimento, p_sexo, p_email, p_telefone, 'S');

        SET v_idpessoa = LAST_INSERT_ID();
    END IF;

    -- Grava cada endereço do array
    SET v_total = JSON_LENGTH(p_enderecos);

    WHILE v_i < v_total DO
        SET v_cep    = JSON_UNQUOTE(JSON_EXTRACT(p_enderecos, CONCAT('$[', v_i, '].cep')));
        SET v_numero = JSON_UNQUOTE(JSON_EXTRACT(p_enderecos, CONCAT('$[', v_i, '].numero')));

        -- complemento é opcional: se faltar ou vier null, grava vazio
        SET v_comp_json = JSON_EXTRACT(p_enderecos, CONCAT('$[', v_i, '].complemento'));
        IF v_comp_json IS NULL OR JSON_TYPE(v_comp_json) = 'NULL' THEN
            SET v_complemento = '';
        ELSE
            SET v_complemento = JSON_UNQUOTE(v_comp_json);
        END IF;

        INSERT INTO endereco (idpessoa, cep, numero, complemento)
        VALUES (v_idpessoa, v_cep, v_numero, v_complemento);

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT v_idpessoa AS idpessoa;
END$$

DELIMITER ;

-- Teste:
-- CALL sp_cadastrar_pessoa('Carlos Lima', 99900011122, '1993-04-04', 'M', 'carlos@email.com', 79999990009,
--   '[{"cep":"49000000","numero":"10","complemento":"Casa"},{"cep":"49010000","numero":"55","complemento":"Trabalho"}]');
