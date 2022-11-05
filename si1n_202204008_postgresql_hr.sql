
/*Esse começo do script promove uma limpeza no banco de dados, 
 * faz uma remoção, caso existam, do BD "uvv" e do usuário
 *"michela", para então criar o usuário "Postgres" e o 
 *Banco de Dados "UVV"*/


---------------------------------------------------------
--deletando o banco de dados UVV
drop database if exists uvv;

-- deletando o usuário michela
drop user if exists michela;

--criando usuário
create user michela with
nosuperuser
createdb
createrole
ENCRYPTED PASSWORD '555555';

--criando o banco de dados uvv 
create database uvv 
owner =  'michela'
template = template0
encoding = 'UTF-8'
lc_collate = 'pt_BR.UTF-8'
lc_ctype = 'pt_BR.UTF-8';


















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


/*----------------------------------------------------------
 *                                                          /
 *        a partir daqui serão criadas as tabelas           / 
 *                                                          /
 * --------------------------------------------------------*/                            


----------------------- REGIÕES ----------------------------
/*Aqui será cria criada a tabela regioes
 * com o campo "id_região", que será uma Primary Key
 * e o campo "nome", que será uma alternative key*/
CREATE TABLE hr.regioes (
	id_regiao int NOT null primary key,
	nome varchar(25) NOT null unique
);

------------------------- PAÍSES ----------------------------
/*Criação da tabela com as informações dos paises com
 * o campo "id_pais", que será uma primary key,
 * o campo "nome", que será uma alternative key
 * e o campo "id_regiao", que será uma foreign key*/
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
 * com o campo "id_localizacao", que será uma primary key,
 * o campo "id_pais", que será uma foreign key,
 * e demais informações                                  */
create table hr.localizacoes (
	id_localizacao int not null primary key,
	endereco varchar(50),
	cep varchar(12),
	cidade varchar(50),
	uf varchar(20),
	id_pais char(2) 
);


--Aplicando a foreign key da tabela localizacoes" 
alter table hr.localizacoes 
	add constraint fk_pais
	foreign key (id_pais)
	references hr.paises (id_pais)
;

----------------------DEPARTAMENTOS ------------------------
/* criação da tabela com as informações dos departamentos
 * com os campos: id_departamento (PK), nome (AK), 
 * id_localizacao e id_gerente (FK)
----------------------------------------------------------*/
create table hr.departamentos (
	id_departamento int not null primary key,
	nome varchar(50) unique,
	id_localizacao int, 
	id_gerente int 
);

--Aplicando a foreign key da tabela "departamentos"
alter table hr.departamentos 
	add constraint fk_localizacao 
	foreign key (id_localizacao)
	references hr.localizacoes (id_localizacao)
;


create table hr.empregados (
	id_empregado int not null primary key,
	nome varchar(75) not null,
	email varchar(35) not null unique,
	data_contratacao date not null,
	id_cargo varchar(10) not null,
	salario decimal(8,2),
	comissao decimal(4,2),
	id_departamento int,
	id_supervisor int 
);


create table hr.cargos (
	id_cargo varchar(10) not null primary key,
	cargo varchar(35) not null unique,
	salario_minimo decimal(8,2),
	salario_maximo decimal(8,2) 
);

create table hr.historico_cargos (
	id_empregado int not null, 
	data_inicial date not null,
	data_final date not null,
	id_cargo varchar(10) not null, 
	id_departamento int,
	primary key(id_empregado, data_inicial)
);


--Aplicando a foreign key da tabela departamentos" 
alter table hr.departamentos   
	add constraint fk_gerente
	foreign key (id_gerente)
	references hr.empregados (id_empregado)
;

--Aplicando a foreign key da tabela empregados" 
alter table hr.empregados  
	add constraint fk_departamento
	foreign key (id_departamento)
	references hr.departamentos (id_departamento)
;

--Aplicando a foreign key da tabela empregados" 
alter table hr.empregados  
	add constraint fk_supervisor
	foreign key (id_supervisor)
	references hr.empregados (id_empregado)
;

--Relacionando a tabela "empregados" com "cargos" 
alter table hr.empregados  
	add constraint fk_cargo
	foreign key (id_cargo)
	references hr.cargos (id_cargo)
;

--Aplicando a foreign key da tabela "historico_cargos" 
alter table hr.historico_cargos   
	add constraint pfk_empregado
	foreign key (id_empregado)
	references hr.empregados (id_empregado)
;

--Aplicando a foreign key da tabela "historico_cargos" 
alter table hr.historico_cargos   
	add constraint fk_cargo
	foreign key (id_cargo)
	references hr.cargos (id_cargo)
;

--Aplicando a foreign key da tabela "historico_cargos" 
alter table hr.historico_cargos   
	add constraint fk_departamento
	foreign key (id_departamento)
	references hr.departamentos (id_departamento)
;

	