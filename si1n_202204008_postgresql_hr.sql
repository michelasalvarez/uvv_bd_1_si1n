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


\c "dbname=uvv user=michela password=555555"

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
COMMENT ON TABLE hr.regioes IS 'Tabela que armazena as informações das regiões.';
COMMENT ON COLUMN hr.regioes.id_regiao IS 'Id.regiao será uma PK na tabela.';


------------------------- PAÍSES ----------------------------
/*Criação da tabela com as informações dos paises com
 * o campo "id_pais", que será uma primary key,
 * o campo "nome", que será uma alternative key
 * e o campo "id_regiao", que será uma foreign key*/
CREATE TABLE hr.paises (
	id_pais char(2) NOT null primary key,
	nome varchar(50) NOT null unique,
	id_regiao int not null
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


---------------------EMPREGADOS ------------------------
/* criação da tabela com as informações dos empregados
 * com os campos: id_empregado (pK), nome, email (AK)
 * data_contratacao, id_cargo, salario, comissao, 
 * id_departamento e id_supervisor
------------------------------------------------------*/
create table hr.empregados (
	id_empregado int not null primary key,
	nome varchar(75) not null,
	email varchar(35) not null unique,
	telefone varchar(20),
	data_contratacao date not null,
	id_cargo varchar(10) not null,
	salario decimal(8,2),
	comissao decimal(4,2),
	id_departamento int,
	id_supervisor int 
);


--------------------- CARGOS- ------------------------
/* criação da tabela com as informações dos cargos
 * com os campos: id_cargo (pK), cargo (AK),
 * salario_minimo e salario_maximo
------------------------------------------------------*/
create table hr.cargos (
	id_cargo varchar(10) not null primary key,
	cargo varchar(35) not null unique,
	salario_minimo decimal(8,2),
	salario_maximo decimal(8,2) 
);

------------------HISTORICO_CARGOS----------------------
/* criação da tabela com as informações dos históricos
 * dos cargos, com os campos: id_empregado (PFK), 
 * data_incial, data_final, id_cargo (FK), id_departamento(FK)
------------------------------------------------------*/
create table hr.historico_cargos (
	id_empregado int not null, 
	data_inicial date not null,
	data_final date not null,
	id_cargo varchar(10) not null, 
	id_departamento int,
	primary key(id_empregado, data_inicial)
);

/*----------------------------------------------------------
 *                                                          /
 *        a partir daqui as tabelas serão RELACIONADAS      / 
 *                                                          /
 * --------------------------------------------------------*/  

--Relacionando a tabela "paises" com a tabela "regiões" 
alter table hr.paises 
	add constraint fk_regiao
	foreign key (id_regiao)
	references hr.regioes (id_regiao)
;

--Relacionando a tabela "localizacoes" com a tabela "países" 
alter table hr.localizacoes 
	add constraint fk_pais
	foreign key (id_pais)
	references hr.paises (id_pais)
;

--Aplicando a foreign key da tabela departamentos" 
alter table hr.departamentos   
	add constraint fk_gerente
	foreign key (id_gerente)
	references hr.empregados (id_empregado)
;

--Relacionando a tabela "departamentos" com a tabela "localizacoes"
alter table hr.departamentos 
	add constraint fk_localizacao 
	foreign key (id_localizacao)
	references hr.localizacoes (id_localizacao)
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

-------------------------------------------------------------------
-- POPULANDO AS TABELAS
-------------------------------------------------------------------

Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1000,'1297 Via Cola di Rie','00989','Roma',null,'IT');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1100,'93091 Calle della Testa','10934','Venice',null,'IT');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1200,'2017 Shinjuku-ku','1689','Tokyo','Tokyo Prefecture','JP');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1300,'9450 Kamiya-cho','6823','Hiroshima',null,'JP');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1400,'2014 Jabberwocky Rd','26192','Southlake','Texas','US');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1500,'2011 Interiors Blvd','99236','South San Francisco','California','US');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1600,'2007 Zagora St','50090','South Brunswick','New Jersey','US');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1700,'2004 Charade Rd','98199','Seattle','Washington','US');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1800,'147 Spadina Ave','M5V 2L7','Toronto','Ontario','CA');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (1900,'6092 Boxwood St','YSW 9T2','Whitehorse','Yukon','CA');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2000,'40-5-12 Laogianggen','190518','Beijing',null,'CN');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2100,'1298 Vileparle (E)','490231','Bombay','Maharashtra','IN');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2200,'12-98 Victoria Street','2901','Sydney','New South Wales','AU');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2300,'198 Clementi North','540198','Singapore',null,'SG');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2400,'8204 Arthur St',null,'London',null,'UK');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2500,'Magdalen Centre, The Oxford Science Park','OX9 9ZB','Oxford','Oxford','UK');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2600,'9702 Chester Road','09629850293','Stretford','Manchester','UK');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2700,'Schwanthalerstr. 7031','80925','Munich','Bavaria','DE');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2800,'Rua Frei Caneca 1360 ','01307-002','Sao Paulo','Sao Paulo','BR');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (2900,'20 Rue des Corps-Saints','1730','Geneva','Geneve','CH');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (3000,'Murtenstrasse 921','3095','Bern','BE','CH');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (3100,'Pieter Breughelstraat 837','3029SK','Utrecht','Utrecht','NL');
Insert into hr.localizacoes (id_localizacao. endereco, cep, cidade, uf, id_pais) values (3200,'Mariano Escobedo 9991','11932','Mexico City','Distrito Federal,','MX');


Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('AD_PRES','President',20080,40000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('AD_VP','Administration Vice President',15000,30000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('AD_ASST','Administration Assistant',3000,6000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('FI_MGR','Finance Manager',8200,16000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('FI_ACCOUNT','Accountant',4200,9000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('AC_MGR','Accounting Manager',8200,16000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('AC_ACCOUNT','Public Accountant',4200,9000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('SA_MAN','Sales Manager',10000,20080);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('SA_REP','Sales Representative',6000,12008);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('PU_MAN','Purchasing Manager',8000,15000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('PU_CLERK','Purchasing Clerk',2500,5500);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('ST_MAN','Stock Manager',5500,8500);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('ST_CLERK','Stock Clerk',2008,5000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('SH_CLERK','Shipping Clerk',2500,5500);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('IT_PROG','Programmer',4000,10000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('MK_MAN','Marketing Manager',9000,15000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('MK_REP','Marketing Representative',4000,9000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('HR_REP','Human Resources Representative',4000,9000);
Insert into hr.cargos (id_cargo, cargo, salario_minimo, salario_maximo) values ('PR_REP','Public Relations Representative',4500,10500);


Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (102,to_date('13-JAN-01','DD-MON-RR'),to_date('24-JUL-06','DD-MON-RR'),'IT_PROG',60);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (101,to_date('21-SEP-97','DD-MON-RR'),to_date('27-OCT-01','DD-MON-RR'),'AC_ACCOUNT',110);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (101,to_date('28-OCT-01','DD-MON-RR'),to_date('15-MAR-05','DD-MON-RR'),'AC_MGR',110);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (201,to_date('17-FEB-04','DD-MON-RR'),to_date('19-DEC-07','DD-MON-RR'),'MK_REP',20);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (114,to_date('24-MAR-06','DD-MON-RR'),to_date('31-DEC-07','DD-MON-RR'),'ST_CLERK',50);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (122,to_date('01-JAN-07','DD-MON-RR'),to_date('31-DEC-07','DD-MON-RR'),'ST_CLERK',50);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (200,to_date('17-SEP-95','DD-MON-RR'),to_date('17-JUN-01','DD-MON-RR'),'AD_ASST',90);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (176,to_date('24-MAR-06','DD-MON-RR'),to_date('31-DEC-06','DD-MON-RR'),'SA_REP',80);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (176,to_date('01-JAN-07','DD-MON-RR'),to_date('31-DEC-07','DD-MON-RR'),'SA_MAN',80);
Insert into hr.historico_cargos (id_empregado, data_inicial, data_final, id_cargo, id_departamento) values (200,to_date('01-JUL-02','DD-MON-RR'),to_date('31-DEC-06','DD-MON-RR'),'AC_ACCOUNT',90);


Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (100,'Steven','King','SKING','515.123.4567',to_date('17-JUN-03','DD-MON-RR'),'AD_PRES',24000,null,null,90);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (101,'Neena','Kochhar','NKOCHHAR','515.123.4568',to_date('21-SEP-05','DD-MON-RR'),'AD_VP',17000,null,100,90);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (102,'Lex','De Haan','LDEHAAN','515.123.4569',to_date('13-JAN-01','DD-MON-RR'),'AD_VP',17000,null,100,90);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (103,'Alexander','Hunold','AHUNOLD','590.423.4567',to_date('03-JAN-06','DD-MON-RR'),'IT_PROG',9000,null,102,60);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (104,'Bruce','Ernst','BERNST','590.423.4568',to_date('21-MAY-07','DD-MON-RR'),'IT_PROG',6000,null,103,60);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (105,'David','Austin','DAUSTIN','590.423.4569',to_date('25-JUN-05','DD-MON-RR'),'IT_PROG',4800,null,103,60);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (106,'Valli','Pataballa','VPATABAL','590.423.4560',to_date('05-FEB-06','DD-MON-RR'),'IT_PROG',4800,null,103,60);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (107,'Diana','Lorentz','DLORENTZ','590.423.5567',to_date('07-FEB-07','DD-MON-RR'),'IT_PROG',4200,null,103,60);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (108,'Nancy','Greenberg','NGREENBE','515.124.4569',to_date('17-AUG-02','DD-MON-RR'),'FI_MGR',12008,null,101,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (109,'Daniel','Faviet','DFAVIET','515.124.4169',to_date('16-AUG-02','DD-MON-RR'),'FI_ACCOUNT',9000,null,108,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (110,'John','Chen','JCHEN','515.124.4269',to_date('28-SEP-05','DD-MON-RR'),'FI_ACCOUNT',8200,null,108,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (111,'Ismael','Sciarra','ISCIARRA','515.124.4369',to_date('30-SEP-05','DD-MON-RR'),'FI_ACCOUNT',7700,null,108,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (112,'Jose Manuel','Urman','JMURMAN','515.124.4469',to_date('07-MAR-06','DD-MON-RR'),'FI_ACCOUNT',7800,null,108,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (113,'Luis','Popp','LPOPP','515.124.4567',to_date('07-DEC-07','DD-MON-RR'),'FI_ACCOUNT',6900,null,108,100);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (114,'Den','Raphaely','DRAPHEAL','515.127.4561',to_date('07-DEC-02','DD-MON-RR'),'PU_MAN',11000,null,100,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (115,'Alexander','Khoo','AKHOO','515.127.4562',to_date('18-MAY-03','DD-MON-RR'),'PU_CLERK',3100,null,114,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (116,'Shelli','Baida','SBAIDA','515.127.4563',to_date('24-DEC-05','DD-MON-RR'),'PU_CLERK',2900,null,114,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (117,'Sigal','Tobias','STOBIAS','515.127.4564',to_date('24-JUL-05','DD-MON-RR'),'PU_CLERK',2800,null,114,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (118,'Guy','Himuro','GHIMURO','515.127.4565',to_date('15-NOV-06','DD-MON-RR'),'PU_CLERK',2600,null,114,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (119,'Karen','Colmenares','KCOLMENA','515.127.4566',to_date('10-AUG-07','DD-MON-RR'),'PU_CLERK',2500,null,114,30);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (120,'Matthew','Weiss','MWEISS','650.123.1234',to_date('18-JUL-04','DD-MON-RR'),'ST_MAN',8000,null,100,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (121,'Adam','Fripp','AFRIPP','650.123.2234',to_date('10-APR-05','DD-MON-RR'),'ST_MAN',8200,null,100,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (122,'Payam','Kaufling','PKAUFLIN','650.123.3234',to_date('01-MAY-03','DD-MON-RR'),'ST_MAN',7900,null,100,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (123,'Shanta','Vollman','SVOLLMAN','650.123.4234',to_date('10-OCT-05','DD-MON-RR'),'ST_MAN',6500,null,100,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (124,'Kevin','Mourgos','KMOURGOS','650.123.5234',to_date('16-NOV-07','DD-MON-RR'),'ST_MAN',5800,null,100,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (125,'Julia','Nayer','JNAYER','650.124.1214',to_date('16-JUL-05','DD-MON-RR'),'ST_CLERK',3200,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (126,'Irene','Mikkilineni','IMIKKILI','650.124.1224',to_date('28-SEP-06','DD-MON-RR'),'ST_CLERK',2700,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (127,'James','Landry','JLANDRY','650.124.1334',to_date('14-JAN-07','DD-MON-RR'),'ST_CLERK',2400,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (128,'Steven','Markle','SMARKLE','650.124.1434',to_date('08-MAR-08','DD-MON-RR'),'ST_CLERK',2200,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (129,'Laura','Bissot','LBISSOT','650.124.5234',to_date('20-AUG-05','DD-MON-RR'),'ST_CLERK',3300,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (130,'Mozhe','Atkinson','MATKINSO','650.124.6234',to_date('30-OCT-05','DD-MON-RR'),'ST_CLERK',2800,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (131,'James','Marlow','JAMRLOW','650.124.7234',to_date('16-FEB-05','DD-MON-RR'),'ST_CLERK',2500,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (132,'TJ','Olson','TJOLSON','650.124.8234',to_date('10-APR-07','DD-MON-RR'),'ST_CLERK',2100,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (133,'Jason','Mallin','JMALLIN','650.127.1934',to_date('14-JUN-04','DD-MON-RR'),'ST_CLERK',3300,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (134,'Michael','Rogers','MROGERS','650.127.1834',to_date('26-AUG-06','DD-MON-RR'),'ST_CLERK',2900,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (135,'Ki','Gee','KGEE','650.127.1734',to_date('12-DEC-07','DD-MON-RR'),'ST_CLERK',2400,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (136,'Hazel','Philtanker','HPHILTAN','650.127.1634',to_date('06-FEB-08','DD-MON-RR'),'ST_CLERK',2200,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (137,'Renske','Ladwig','RLADWIG','650.121.1234',to_date('14-JUL-03','DD-MON-RR'),'ST_CLERK',3600,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (138,'Stephen','Stiles','SSTILES','650.121.2034',to_date('26-OCT-05','DD-MON-RR'),'ST_CLERK',3200,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (139,'John','Seo','JSEO','650.121.2019',to_date('12-FEB-06','DD-MON-RR'),'ST_CLERK',2700,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (140,'Joshua','Patel','JPATEL','650.121.1834',to_date('06-APR-06','DD-MON-RR'),'ST_CLERK',2500,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (141,'Trenna','Rajs','TRAJS','650.121.8009',to_date('17-OCT-03','DD-MON-RR'),'ST_CLERK',3500,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (142,'Curtis','Davies','CDAVIES','650.121.2994',to_date('29-JAN-05','DD-MON-RR'),'ST_CLERK',3100,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (143,'Randall','Matos','RMATOS','650.121.2874',to_date('15-MAR-06','DD-MON-RR'),'ST_CLERK',2600,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (144,'Peter','Vargas','PVARGAS','650.121.2004',to_date('09-JUL-06','DD-MON-RR'),'ST_CLERK',2500,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (145,'John','Russell','JRUSSEL','011.44.1344.429268',to_date('01-OCT-04','DD-MON-RR'),'SA_MAN',14000,0.4,100,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (146,'Karen','Partners','KPARTNER','011.44.1344.467268',to_date('05-JAN-05','DD-MON-RR'),'SA_MAN',13500,0.3,100,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (147,'Alberto','Errazuriz','AERRAZUR','011.44.1344.429278',to_date('10-MAR-05','DD-MON-RR'),'SA_MAN',12000,0.3,100,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (148,'Gerald','Cambrault','GCAMBRAU','011.44.1344.619268',to_date('15-OCT-07','DD-MON-RR'),'SA_MAN',11000,0.3,100,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (149,'Eleni','Zlotkey','EZLOTKEY','011.44.1344.429018',to_date('29-JAN-08','DD-MON-RR'),'SA_MAN',10500,0.2,100,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (150,'Peter','Tucker','PTUCKER','011.44.1344.129268',to_date('30-JAN-05','DD-MON-RR'),'SA_REP',10000,0.3,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (151,'David','Bernstein','DBERNSTE','011.44.1344.345268',to_date('24-MAR-05','DD-MON-RR'),'SA_REP',9500,0.25,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (152,'Peter','Hall','PHALL','011.44.1344.478968',to_date('20-AUG-05','DD-MON-RR'),'SA_REP',9000,0.25,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (153,'Christopher','Olsen','COLSEN','011.44.1344.498718',to_date('30-MAR-06','DD-MON-RR'),'SA_REP',8000,0.2,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (154,'Nanette','Cambrault','NCAMBRAU','011.44.1344.987668',to_date('09-DEC-06','DD-MON-RR'),'SA_REP',7500,0.2,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (155,'Oliver','Tuvault','OTUVAULT','011.44.1344.486508',to_date('23-NOV-07','DD-MON-RR'),'SA_REP',7000,0.15,145,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (156,'Janette','King','JKING','011.44.1345.429268',to_date('30-JAN-04','DD-MON-RR'),'SA_REP',10000,0.35,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (157,'Patrick','Sully','PSULLY','011.44.1345.929268',to_date('04-MAR-04','DD-MON-RR'),'SA_REP',9500,0.35,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (158,'Allan','McEwen','AMCEWEN','011.44.1345.829268',to_date('01-AUG-04','DD-MON-RR'),'SA_REP',9000,0.35,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (159,'Lindsey','Smith','LSMITH','011.44.1345.729268',to_date('10-MAR-05','DD-MON-RR'),'SA_REP',8000,0.3,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (160,'Louise','Doran','LDORAN','011.44.1345.629268',to_date('15-DEC-05','DD-MON-RR'),'SA_REP',7500,0.3,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (161,'Sarath','Sewall','SSEWALL','011.44.1345.529268',to_date('03-NOV-06','DD-MON-RR'),'SA_REP',7000,0.25,146,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (162,'Clara','Vishney','CVISHNEY','011.44.1346.129268',to_date('11-NOV-05','DD-MON-RR'),'SA_REP',10500,0.25,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (163,'Danielle','Greene','DGREENE','011.44.1346.229268',to_date('19-MAR-07','DD-MON-RR'),'SA_REP',9500,0.15,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (164,'Mattea','Marvins','MMARVINS','011.44.1346.329268',to_date('24-JAN-08','DD-MON-RR'),'SA_REP',7200,0.1,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (165,'David','Lee','DLEE','011.44.1346.529268',to_date('23-FEB-08','DD-MON-RR'),'SA_REP',6800,0.1,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (166,'Sundar','Ande','SANDE','011.44.1346.629268',to_date('24-MAR-08','DD-MON-RR'),'SA_REP',6400,0.1,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (167,'Amit','Banda','ABANDA','011.44.1346.729268',to_date('21-APR-08','DD-MON-RR'),'SA_REP',6200,0.1,147,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (168,'Lisa','Ozer','LOZER','011.44.1343.929268',to_date('11-MAR-05','DD-MON-RR'),'SA_REP',11500,0.25,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (169,'Harrison','Bloom','HBLOOM','011.44.1343.829268',to_date('23-MAR-06','DD-MON-RR'),'SA_REP',10000,0.2,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (170,'Tayler','Fox','TFOX','011.44.1343.729268',to_date('24-JAN-06','DD-MON-RR'),'SA_REP',9600,0.2,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (171,'William','Smith','WSMITH','011.44.1343.629268',to_date('23-FEB-07','DD-MON-RR'),'SA_REP',7400,0.15,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (172,'Elizabeth','Bates','EBATES','011.44.1343.529268',to_date('24-MAR-07','DD-MON-RR'),'SA_REP',7300,0.15,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (173,'Sundita','Kumar','SKUMAR','011.44.1343.329268',to_date('21-APR-08','DD-MON-RR'),'SA_REP',6100,0.1,148,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (174,'Ellen','Abel','EABEL','011.44.1644.429267',to_date('11-MAY-04','DD-MON-RR'),'SA_REP',11000,0.3,149,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (175,'Alyssa','Hutton','AHUTTON','011.44.1644.429266',to_date('19-MAR-05','DD-MON-RR'),'SA_REP',8800,0.25,149,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (176,'Jonathon','Taylor','JTAYLOR','011.44.1644.429265',to_date('24-MAR-06','DD-MON-RR'),'SA_REP',8600,0.2,149,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (177,'Jack','Livingston','JLIVINGS','011.44.1644.429264',to_date('23-APR-06','DD-MON-RR'),'SA_REP',8400,0.2,149,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (178,'Kimberely','Grant','KGRANT','011.44.1644.429263',to_date('24-MAY-07','DD-MON-RR'),'SA_REP',7000,0.15,149,null);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (179,'Charles','Johnson','CJOHNSON','011.44.1644.429262',to_date('04-JAN-08','DD-MON-RR'),'SA_REP',6200,0.1,149,80);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (180,'Winston','Taylor','WTAYLOR','650.507.9876',to_date('24-JAN-06','DD-MON-RR'),'SH_CLERK',3200,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (181,'Jean','Fleaur','JFLEAUR','650.507.9877',to_date('23-FEB-06','DD-MON-RR'),'SH_CLERK',3100,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (182,'Martha','Sullivan','MSULLIVA','650.507.9878',to_date('21-JUN-07','DD-MON-RR'),'SH_CLERK',2500,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (183,'Girard','Geoni','GGEONI','650.507.9879',to_date('03-FEB-08','DD-MON-RR'),'SH_CLERK',2800,null,120,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (184,'Nandita','Sarchand','NSARCHAN','650.509.1876',to_date('27-JAN-04','DD-MON-RR'),'SH_CLERK',4200,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (185,'Alexis','Bull','ABULL','650.509.2876',to_date('20-FEB-05','DD-MON-RR'),'SH_CLERK',4100,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (186,'Julia','Dellinger','JDELLING','650.509.3876',to_date('24-JUN-06','DD-MON-RR'),'SH_CLERK',3400,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (187,'Anthony','Cabrio','ACABRIO','650.509.4876',to_date('07-FEB-07','DD-MON-RR'),'SH_CLERK',3000,null,121,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (188,'Kelly','Chung','KCHUNG','650.505.1876',to_date('14-JUN-05','DD-MON-RR'),'SH_CLERK',3800,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (189,'Jennifer','Dilly','JDILLY','650.505.2876',to_date('13-AUG-05','DD-MON-RR'),'SH_CLERK',3600,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (190,'Timothy','Gates','TGATES','650.505.3876',to_date('11-JUL-06','DD-MON-RR'),'SH_CLERK',2900,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (191,'Randall','Perkins','RPERKINS','650.505.4876',to_date('19-DEC-07','DD-MON-RR'),'SH_CLERK',2500,null,122,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (192,'Sarah','Bell','SBELL','650.501.1876',to_date('04-FEB-04','DD-MON-RR'),'SH_CLERK',4000,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (193,'Britney','Everett','BEVERETT','650.501.2876',to_date('03-MAR-05','DD-MON-RR'),'SH_CLERK',3900,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (194,'Samuel','McCain','SMCCAIN','650.501.3876',to_date('01-JUL-06','DD-MON-RR'),'SH_CLERK',3200,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (195,'Vance','Jones','VJONES','650.501.4876',to_date('17-MAR-07','DD-MON-RR'),'SH_CLERK',2800,null,123,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (196,'Alana','Walsh','AWALSH','650.507.9811',to_date('24-APR-06','DD-MON-RR'),'SH_CLERK',3100,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (197,'Kevin','Feeney','KFEENEY','650.507.9822',to_date('23-MAY-06','DD-MON-RR'),'SH_CLERK',3000,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (198,'Donald','OConnell','DOCONNEL','650.507.9833',to_date('21-JUN-07','DD-MON-RR'),'SH_CLERK',2600,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (199,'Douglas','Grant','DGRANT','650.507.9844',to_date('13-JAN-08','DD-MON-RR'),'SH_CLERK',2600,null,124,50);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (200,'Jennifer','Whalen','JWHALEN','515.123.4444',to_date('17-SEP-03','DD-MON-RR'),'AD_ASST',4400,null,101,10);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (201,'Michael','Hartstein','MHARTSTE','515.123.5555',to_date('17-FEB-04','DD-MON-RR'),'MK_MAN',13000,null,100,20);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (202,'Pat','Fay','PFAY','603.123.6666',to_date('17-AUG-05','DD-MON-RR'),'MK_REP',6000,null,201,20);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (203,'Susan','Mavris','SMAVRIS','515.123.7777',to_date('07-JUN-02','DD-MON-RR'),'HR_REP',6500,null,101,40);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (204,'Hermann','Baer','HBAER','515.123.8888',to_date('07-JUN-02','DD-MON-RR'),'PR_REP',10000,null,101,70);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (205,'Shelley','Higgins','SHIGGINS','515.123.8080',to_date('07-JUN-02','DD-MON-RR'),'AC_MGR',12008,null,101,110);
Insert into hr.empregados (id_empregado, nome, email, telefone, data_contratacao, id_cargo, salario, comissao, id_departamento, id_supervisor) values (206,'William','Gietz','WGIETZ','515.123.8181',to_date('07-JUN-02','DD-MON-RR'),'AC_ACCOUNT',8300,null,205,110);


Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (10,'Administration',200,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (20,'Marketing',201,1800);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (30,'Purchasing',114,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (40,'Human Resources',203,2400);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (50,'Shipping',121,1500);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (60,'IT',103,1400);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (70,'Public Relations',204,2700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (80,'Sales',145,2500);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (90,'Executive',100,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (100,'Finance',108,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (110,'Accounting',205,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (120,'Treasury',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (130,'Corporate Tax',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (140,'Control And Credit',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (150,'Shareholder Services',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (160,'Benefits',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (170,'Manufacturing',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (180,'Construction',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (190,'Contracting',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (200,'Operations',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (210,'IT Support',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (220,'NOC',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (230,'IT Helpdesk',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (240,'Government Sales',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (250,'Retail Sales',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (260,'Recruiting',null,1700);
Insert into hr.departamentos (id_departamento, nome, id_localizacao, id_gerente) values (270,'Payroll',null,1700);


Insert into hr.paises (id_paises, nome, id_regiao) values ('AR','Argentina',2);
Insert into hr.paises (id_paises, nome, id_regiao) values ('AU','Australia',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('BE','Belgium',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('BR','Brazil',2);
Insert into hr.paises (id_paises, nome, id_regiao) values ('CA','Canada',2);
Insert into hr.paises (id_paises, nome, id_regiao) values ('CH','Switzerland',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('CN','China',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('DE','Germany',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('DK','Denmark',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('EG','Egypt',4);
Insert into hr.paises (id_paises, nome, id_regiao) values ('FR','France',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('IL','Israel',4);
Insert into hr.paises (id_paises, nome, id_regiao) values ('IN','India',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('IT','Italy',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('JP','Japan',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('KW','Kuwait',4);
Insert into hr.paises (id_paises, nome, id_regiao) values ('ML','Malaysia',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('MX','Mexico',2);
Insert into hr.paises (id_paises, nome, id_regiao) values ('NG','Nigeria',4);
Insert into hr.paises (id_paises, nome, id_regiao) values ('NL','Netherlands',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('SG','Singapore',3);
Insert into hr.paises (id_paises, nome, id_regiao) values ('UK','United Kingdom',1);
Insert into hr.paises (id_paises, nome, id_regiao) values ('US','United States of America',2);
Insert into hr.paises (id_paises, nome, id_regiao) values ('ZM','Zambia',4);
Insert into hr.paises (id_paises, nome, id_regiao) values ('ZW','Zimbabwe',4);


Insert into hr.regioes (id_regiao, nome) values (1,'Europe');
Insert into hr.regioes (id_regiao, nome) values (2,'Americas');
Insert into hr.regioes (id_regiao, nome) values (3,'Asia');
Insert into hr.regioes (id_regiao, nome) values (4,'Middle East and Africa');
