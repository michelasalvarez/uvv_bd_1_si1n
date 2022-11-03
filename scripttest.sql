-- test

-----------------------------------------------------------
/*tem que explicar no comentário sobre a criação do usuário 
"dono" do banco de dados uvv, e sobre a criação do schema. */
create database uvv;
create schema hr;

---------- Mostra qual é o atual SEARCH PATH --------------
show search_path;


------------------------------------------------------------
/* Aqui será confugirado o SEARCH PATH do usuário postgres
 * para que os objetos do projeto lógico sejam
 * criados no  schema HR 
-----------------------------------------------------------*/
alter user postgres 
set search_path to uvv, "$user", public;


-------- Confere se HR ficou como esquema principal --------
select current_schema();


----------------------- REGIÕES ----------------------------
/*Aqui será cria criada a tabela regioes
 * o campo "id_região" será uma Primary Key
 * o campo "nome" será uma alternative key*/
CREATE TABLE hr.regioes (
	id_regiao int NOT null primary key,
	nome varchar(25) NOT null unique
);

------------------------- PAÍSES ----------------------------
/*Criação da tabela com as informações dos paises 
 * o campo "id_pais" será uma primary key
 * o campo "nome" será uma alternative key
 * o campo "id_regiao" será uma foreign key*/
CREATE TABLE hr.paises (
	id_pais char(2) NOT null primary key,
	nome varchar(50) NOT null unique,
	id_regiao int not null,
	constraint fk_regiao
		foreign key(id_regiao)
			references hr.regioes(id_regiao) 
);

----------------------LOCALIZAÇÕES--------------------------
/*Criação da tabela com as informações das localizações 
 * o campo "id_localizacao" será uma primary key
 * o campo "id_região será uma foreign key*/
create table hr.localizacoes (
	id_localizacao int not null primary key,
	endereco varchar(50),
	cep varchar(12),
	cidade varchar(50),
	uf varchar(20),
	id_pais char(2) 
);
--Aplicando a foreign key no campo "id_pais"
alter table hr.localizacoes 
	add constraint fk_localizacao
	foreign key (id_pais)
	references hr.paises (id_pais)
;


create table 