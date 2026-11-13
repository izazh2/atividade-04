USE bd_aula_backend;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_atendimentoitem_bi_valida$$

-- 10) Parte 1 (ANTES de inserir): bloqueia se a quantidade for maior que o estoque.
CREATE TRIGGER trg_atendimentoitem_bi_valida
BEFORE INSERT ON atendimentoitem
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT DEFAULT NULL;
    DECLARE v_msg VARCHAR(128);

    -- Busca o estoque do item. Se for serviço, não há linha em estoque
    -- e v_estoque fica NULL (nesse caso não valida nada).
    SELECT quantidade_estoque INTO v_estoque
      FROM estoque
     WHERE iditem = NEW.iditem;

    -- Quantidade maior que o estoque: cancela o registro e mostra a mensagem no console
    IF v_estoque IS NOT NULL AND NEW.quantidade_itens > v_estoque THEN
        -- MESSAGE_TEXT não aceita expressão: monta a mensagem antes, em uma variável
        SET v_msg = CONCAT('Estoque insuficiente para o item ', NEW.iditem,
                           ': solicitado ', NEW.quantidade_itens,
                           ', disponivel ', v_estoque, '.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = v_msg;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_atendimentoitem_ai_debita$$

-- 10) Parte 2 (DEPOIS de inserir): debita a quantidade do estoque.
CREATE TRIGGER trg_atendimentoitem_ai_debita
AFTER INSERT ON atendimentoitem
FOR EACH ROW
BEGIN
    -- Para serviço não existe linha em estoque, então o UPDATE não altera nada
    UPDATE estoque
       SET quantidade_estoque = quantidade_estoque - NEW.quantidade_itens
     WHERE iditem = NEW.iditem;
END$$

DELIMITER ;