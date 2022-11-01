create database uvv;

create schema hr;

CREATE TABLE hr.regioes (
	id_regiao int NOT null primary key,
	nome varchar(25) NOT null unique
);

CREATE TABLE hr.paises (
	id_pais char(2) NOT null primary key,
	nome varchar(50) NOT null unique,
	id_regiao int,
	constraint fk_regiao
		foreign key(id_regiao)
			references hr.regioes(id_regiao) 
	);

create table hr.localizacoes (
	id_localizacao int not null primary key,
	endereco varchar(50),
	cep varchar(12),
	cidade varchar(50),
	uf varchar(20),
	id_pais char(2) 
);

alter table hr.localizacoes 
	add constraint fk_localizacao
	foreign key (id_pais)
	references hr.paises (id_pais);