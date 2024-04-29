SET SERVEROUTPUT ON;
CREATE TABLESPACE BDGARA
DATAFILE 'bdgara2.dbf'
SIZE 100M AUTOEXTEND ON;

CREATE OR REPLACE TYPE Episodio AS OBJECT(
    temporada number,
    episodio number,
    nombre varchar2(20)
);

CREATE OR REPLACE TYPE Serie AS OBJECT(
    codigo number,
    titulo varchar2(30),
    pais varchar2(20),
    genero varchar2(20),
    epi REF Episodio
);

--Creamos las tablas de los objeto
DROP TABLE SerieTable;

CREATE TABLE SerieTable of Serie(
  codigo primary key
);

DROP TABLE EpisodioTable;

CREATE TABLE EpisodioTable of Episodio(
    PRIMARY KEY (temporada, episodio)
);

-- Insertar datos en EpisodioTable
INSERT INTO EpisodioTable VALUES(1,1,'Piloto');
INSERT INTO EpisodioTable VALUES(1,2,'Nuevos comienzo');
INSERT INTO EpisodioTable VALUES(1,3,'Manantial');

-- Insertar datos en SerieTable
INSERT INTO SerieTable VALUES (1, 'House', 'Estados Unidos', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 1));
INSERT INTO SerieTable VALUES (2, 'House', 'Estados Unidos', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 2));
INSERT INTO SerieTable VALUES (3, 'House', 'Estados Unidos', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 3));
 
INSERT INTO SerieTable VALUES (4, 'Chernobyl', 'Reino Unido', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 1));
INSERT INTO SerieTable VALUES (5, 'Chernobyl', 'Reino Unido', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 2));
INSERT INTO SerieTable VALUES (6, 'Chernobyl', 'Reino Unido', 'Drama',(SELECT REF(e) FROM EpisodioTable e WHERE e.temporada = 1 AND e.episodio = 3));

--Consultas
SELECT s.codigo,s.titulo,s.pais,s.genero, DEREF(epi).temporada, DEREF(epi).episodio, DEREF(epi).nombre
FROM SerieTable s
WHERE s.codigo = 4;

SELECT s.codigo, s.titulo, DEREF(e).temporada, DEREF(e).episodio, DEREF(e).nombre
FROM SerieTable s, TABLE(s.epi) e
WHERE DEREF(e).temporada = 1 AND DEREF(e).episodio = 1;
    
    -- MISMO EJEMPLO CON nested tables
    
    -- creamos el objeto EPISODIO
CREATE OR REPLACE TYPE Episodio AS OBJECT(
    temporada number,
    episodio number,
    nombre varchar2(20)
);

-- creamos el type que almacena los episodios
-- Cambiamos el AS OBJECT por IS TABLE OF
CREATE OR REPLACE TYPE objEpisodio IS TABLE OF Episodio;

-- creamos la tabla que guarda las series y los episodios
-- vamos a crear una nested table.
DROP TABLE SerieTable;
CREATE TABLE SerieTable (
    codigo number,
    titulo varchar2(30),
    pais varchar2(20),
    genero varchar2(20),
	epi objEpisodio
)NESTED TABLE Epi STORE AS tblepi;

--inserts serie
INSERT INTO SerieTable VALUES (1, 'House', 'Estados Unidos', 'Drama', objEpisodio(
	Episodio (1,1,'Piloto'),
    Episodio (1,2,'Nuevos comienzo'),
    Episodio (1,3,'Manantial')));
INSERT INTO SerieTable VALUES (2, 'Chernobyl', 'Reino Unido', 'Drama', objEpisodio(
	Episodio (1,1,'Piloto'),
    Episodio (1,2,'Nuevos comienzo'),
    Episodio (1,3,'Manantial')));  
    
-- Consultar los episodios de una serie
SELECT s.titulo AS "TITULO",tepi.temporada,tepi.episodio, tepi.nombre
FROM SerieTable s,TABLE(s.epi) tepi
WHERE s.codigo =1;

-- Consultar el primer episodio de la primera temporada de cada serie.
SELECT s.codigo, s.titulo, tepi.temporada, tepi.episodio, tepi.nombre
FROM SerieTable s, TABLE(s.epi) tepi
WHERE tepi.temporada = 1 AND tepi.episodio = 1;