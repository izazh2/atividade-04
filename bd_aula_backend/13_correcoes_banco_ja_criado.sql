-- =====================================================
-- 13) CORRECAO PARA QUEM JA CRIOU O BANCO COM O SCRIPT 02 ANTIGO
-- A coluna entrada_produto.quantidade_entrada estava DECIMAL(10,2), mas o modelo
-- do PDF e a aplicacao (EntradaProduto.QuantidadeEntrada) usam numero inteiro (INT).
-- Quem criar o banco com o script 02 atualizado NAO precisa rodar este arquivo.
-- =====================================================
USE bd_aula_backend;

ALTER TABLE entrada_produto
  MODIFY COLUMN quantidade_entrada INT NOT NULL;
