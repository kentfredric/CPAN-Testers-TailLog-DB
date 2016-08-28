-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sun Aug 28 18:06:38 2016
-- 
;
SET foreign_key_checks=0;
--
-- Table: `test_result`
--
CREATE TABLE `test_result` (
  `accepted`  NOT NULL,
  `filename`  NOT NULL,
  `grade`  NOT NULL,
  `perl_version`  NOT NULL,
  `platform`  NOT NULL,
  `reporter`  NOT NULL,
  `submitted`  NOT NULL,
  `uuid`  NOT NULL,
  PRIMARY KEY (`uuid`)
);
SET foreign_key_checks=1;
