-- =====================================================
-- 2) Script do banco bd_aula_backend (modelagem lógica do PDF)
-- =====================================================
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `bd_aula_backend` DEFAULT CHARACTER SET utf8 ;
USE `bd_aula_backend` ;

-- -----------------------------------------------------
-- Table pessoa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`pessoa` (
  `idpessoa` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cpf` BIGINT(11) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `sexo` CHAR(1) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `telefone` BIGINT(11) NOT NULL,
  `ativo_pessoa` CHAR(1) NOT NULL,
  PRIMARY KEY (`idpessoa`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table endereco
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`endereco` (
  `idendereco` INT NOT NULL AUTO_INCREMENT,
  `idpessoa` INT NOT NULL,
  `cep` CHAR(8) NOT NULL,
  `numero` CHAR(10) NOT NULL,
  `complemento` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`idendereco`),
  INDEX `fk_endereco_pessoa_idx` (`idpessoa` ASC),
  CONSTRAINT `fk_endereco_pessoa`
    FOREIGN KEY (`idpessoa`)
    REFERENCES `bd_aula_backend`.`pessoa` (`idpessoa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table funcionario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`funcionario` (
  `idpessoa` INT NOT NULL,
  `cargo` VARCHAR(20) NOT NULL,
  `data_admissao` DATE NOT NULL,
  PRIMARY KEY (`idpessoa`),
  CONSTRAINT `fk_funcionario_pessoa`
    FOREIGN KEY (`idpessoa`)
    REFERENCES `bd_aula_backend`.`pessoa` (`idpessoa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table atendimento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`atendimento` (
  `idatendimento` INT NOT NULL AUTO_INCREMENT,
  `idpessoa` INT NOT NULL,
  `data_atendimento` DATE NOT NULL,
  `status_atendimento` CHAR(1) NOT NULL,
  PRIMARY KEY (`idatendimento`),
  INDEX `fk_atendimento_pessoa_idx` (`idpessoa` ASC),
  CONSTRAINT `fk_atendimento_pessoa`
    FOREIGN KEY (`idpessoa`)
    REFERENCES `bd_aula_backend`.`pessoa` (`idpessoa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table categoria
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`categoria` (
  `idcategoria` INT NOT NULL AUTO_INCREMENT,
  `categoria` VARCHAR(35) NOT NULL,
  PRIMARY KEY (`idcategoria`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table item
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`item` (
  `iditem` INT NOT NULL AUTO_INCREMENT,
  `idcategoria` INT NOT NULL,
  `item` VARCHAR(40) NOT NULL,
  `descricao_item` VARCHAR(200) NOT NULL,
  `preco` DECIMAL(10,2) NOT NULL,
  `tipo_item` CHAR(1) NOT NULL,
  `ativo_produto_servico` CHAR(1) NOT NULL,
  PRIMARY KEY (`iditem`),
  INDEX `fk_item_categoria_idx` (`idcategoria` ASC),
  CONSTRAINT `fk_item_categoria`
    FOREIGN KEY (`idcategoria`)
    REFERENCES `bd_aula_backend`.`categoria` (`idcategoria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table atendimentoitem
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`atendimentoitem` (
  `idatendimento` INT NOT NULL,
  `iditem` INT NOT NULL,
  `idfuncionario` INT NOT NULL,
  `quantidade_itens` INT NOT NULL,
  `valorunitario_entrada` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`idatendimento`, `iditem`),
  INDEX `fk_atendimentoitem_funcionario_idx` (`idfuncionario` ASC),
  INDEX `fk_atendimentoitem_item_idx` (`iditem` ASC),
  CONSTRAINT `fk_atendimentoitem_funcionario`
    FOREIGN KEY (`idfuncionario`)
    REFERENCES `bd_aula_backend`.`funcionario` (`idpessoa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_atendimentoitem_atendimento`
    FOREIGN KEY (`idatendimento`)
    REFERENCES `bd_aula_backend`.`atendimento` (`idatendimento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_atendimentoitem_item`
    FOREIGN KEY (`iditem`)
    REFERENCES `bd_aula_backend`.`item` (`iditem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table produto
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`produto` (
  `iditem` INT NOT NULL,
  `codigo_preco` INT NOT NULL,
  `preco_venda` DECIMAL(10,2) NOT NULL,
  `unidade` CHAR(10) NOT NULL,
  PRIMARY KEY (`iditem`),
  CONSTRAINT `fk_produto_item`
    FOREIGN KEY (`iditem`)
    REFERENCES `bd_aula_backend`.`item` (`iditem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table estoque
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`estoque` (
  `iditem` INT NOT NULL,
  `quantidade_estoque` INT NOT NULL,
  PRIMARY KEY (`iditem`),
  CONSTRAINT `fk_estoque_produto`
    FOREIGN KEY (`iditem`)
    REFERENCES `bd_aula_backend`.`produto` (`iditem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table entrada_produto
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bd_aula_backend`.`entrada_produto` (
  `identrada_produto` INT NOT NULL AUTO_INCREMENT,
  `iditem` INT NOT NULL,
  `data_entrada_produto` DATE NOT NULL,
  `quantidade_entrada` INT NOT NULL,
  `unidade` CHAR(10) NOT NULL,
  `valor_unitario_entrada` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`identrada_produto`, `iditem`),
  INDEX `fk_entrada_produto_estoque_idx` (`iditem` ASC),
  CONSTRAINT `fk_entrada_produto_estoque`
    FOREIGN KEY (`iditem`)
    REFERENCES `bd_aula_backend`.`estoque` (`iditem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
