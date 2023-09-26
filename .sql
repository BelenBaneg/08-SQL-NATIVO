-- PARA INSTALAR SQLITE BROWSER
-- snap install sqlitebrowser
-- Seteá una Base de Datos
--👉 En tu directorio de trabajo, creá una nueva base de datos de SQLite3 usando el comando:

--sqlite3 imdb-test.sqlite.db
--💡 Esto creará una nueva base de datos llamada imbd_test.sqlite.db. También abrirá el prompt de SQLite3 con la nueva base de datos pre-cargada.

--En el prompt de SQLite3 escribí .help. Deberías ver una lista de todos los comandos que podés escribir en SQLite3 para ver los detalles de la base de datos.

--Seedeá la Base de Datos
--Ahora que sabés cómo setear una base de datos, crear tablas y agregar columnas, bajá esta base de datos que hemos pre-llenado con toda la información de las películas de IMBD.

--Descargá este SQLite DB y guardala en tu computadora.
--Abrí la terminal y andá a la carpeta de la base de datos.
--Escribí este comando para abrir la DB en SQLite:
--sqlite3 imdb-large.sqlite3.db

-----------------------------
SELECT year, COUNT(DISTINCT movies.id)
FROM movies
WHERE id NOT IN (
    SELECT movie_id   
    FROM movies_genres
    WHERE genre = 'M'
    )

GROUP BY year;

-- Año de Nacimiento
SELECT name, year FROM movies WHERE year=2002;


-- 1982
SELECT count(*) FROM movies WHERE year=1982;


-- Stacktors
SELECT * FROM actors WHERE last_name="Stack";


-- Juego del Nombre de la Fama
-- First_Name
SELECT count(*), first_name FROM actors
GROUP BY first_name
ORDER BY count(*) DESC
LIMIT 10;


-- Last_Name
SELECT last_name, COUNT(*) as count
FROM actors
GROUP BY last_name
ORDER BY count DESC
LIMIT 10;


-- Full_Name
SELECT first_name  ' '  last_name as full_name, COUNT(*) as count
FROM actors
GROUP BY full_name
ORDER BY count DESC
LIMIT 10;

----------------

SELECT first_name || ' ' || last_name as full_name, COUNT(*) as count
FROM actors
GROUP BY full_name
ORDER BY count DESC
LIMIT 10;



-- Prolifico
SELECT actors.id, actors.first_name, actors.last_name, COUNT(roles.actor_id) AS roles_count
FROM actors
LEFT JOIN roles ON actors.id = roles.actor_id
GROUP BY actors.id, actors.first_name, actors.last_name
ORDER BY roles_count DESC
LIMIT 100;


-- Fondo del Barril
SELECT genre, COUNT(*) AS num_movies_by_genre
FROM movies_genres
JOIN movies ON movies.id = movies_genres.movie_id
GROUP BY genre
ORDER BY num_movies_by_genre ASC;


-- Braveheart
SELECT actors.first_name, actors.last_name
FROM actors
JOIN roles ON actors.id = roles.actor_id
JOIN movies ON roles.movie_id = movies.id
WHERE movies.name = 'Braveheart' AND movies.year = 1995
ORDER BY actors.last_name;


-- Noir Bisiesto
SELECT DISTINCT directors.first_name, directors.last_name, movies.name, movies.year
FROM directors
JOIN movies_directors ON directors.id = movies_directors.director_id
JOIN movies_genres ON movies_directors.movie_id = movies_genres.movie_id
JOIN movies ON movies_genres.movie_id = movies.id
WHERE movies_genres.genre = 'Film-Noir' AND movies.year % 4 = 0
ORDER BY movies.name;


-- Kevin Bacon
SELECT DISTINCT m.name, a.first_name, a.last_name
FROM actors as a
JOIN roles as r1 ON a.id = r1.actor_id
JOIN movies as m ON r1.movie_id = m.id
JOIN movies_genres mg ON m.id = mg.movie_id
WHERE a.id != (SELECT id FROM actors WHERE first_name = 'Kevin' AND last_name = 'Bacon')
AND m.id IN (
  SELECT DISTINCT m2.id
  FROM movies as m2
  JOIN roles as r2 ON m2.id = r2.movie_id
  JOIN actors as a2 ON r2.actor_id = a2.id
  WHERE a2.id = (SELECT id FROM actors WHERE first_name = 'Kevin' AND last_name = 'Bacon')
)
AND mg.genre = 'Drama'
ORDER BY m.name;
-------------
SELECT movies.name, first_name, last_name
FROM roles
join actors 
ON roles.actor_id = actors.id
join movies
ON roles.movie_id = movies.id
join movies_genres 
ON movies.id = movies_genres.movie_id

WHERE movie_genres.genre = "Drama" 

AND movies.id = 
(SELECT movie_id FROM roles
WHERE actor_id = (select id FROM actors WHERE last_name = "Bacon" AND first_name = "Kevin"))

AND first_name != "Kevin"
AND last_name != "Bacon";


--Actores Inmortales
--¿Cúales son los actores que actuaron en un film antes de 1900 y también en un film después del 2000?

--NOTA: no estamos pidiendo todos los actores pre-1900 y post-2000, sino aquellos que hayan trabajado en ambas eras.

--Comandos que te van a simplificar la tarea.
--show hint
--Deberás usar sub-queries para esta y el INTERSECT o IN keywords.

SELECT DISTINCT a.first_name, a.last_name, a.id
FROM actors as a
WHERE a.id IN (
    SELECT r.actor_id
    FROM roles as r
    --traer a peliculas donde tenga tablas de roles donde su id, sea movie.id
    JOIN movies as m ON r.movie_id = m.id
    --año <1900
    WHERE m.year < 1900
)
INTERSECT
SELECT  DISTINCT a.first_name, a.last_name, a.id
FROM actors as a
WHERE a.id IN (
  SELECT r.actor_id
  FROM roles as r
    JOIN movies as m ON r.movie_id = m.id
      WHERE m.year > 2000
);


--Ocupados en Filmación
--Buscá actores que hayan tenido cinco, o más, roles distintos en la misma película luego del año 1990.

--Escribí un query que retorne el nombre del actor, el nombre de la película y el número de roles distintos que hicieron en esa película (que va a ser ≥5).

--Una cláusula HAVING en SQL especifica que una declaración SQL SELECT solo debe devolver filas donde los valores agregados cumplan con las condiciones especificadas.


SELECT DISTINCT first_name, last_name, m.name, m.year, COUNT(DISTINCT r.role) as cantidad_roles
FROM actors as a
JOIN roles as r ON a.id = r.actor_id 
JOIN movies as m ON m.id = r.movie_id
WHERE m.year > 1990
GROUP BY r.actor_id, m.id
HAVING cantidad_roles >= 5;

----

SELECT first_name, last_name, movies.name, movies.year, COUNT(distinct roles.role)
FROM actors 
JOIN roles
ON actors.id = roles.actor_id 
JOIN movies
ON movies.id = roles.movie_id
WHERE movies.year > 1990
GROUP BY roles.actor_id, movie_id
HAVING COUNT(distinct roles.role) >= 5
LIMIT 10;

-- ♀
--Contá los números de películas que tuvieron sólo actrices. Dividilas por año.

--Empezá por incluir películas sin reparto pero, luego, estrechá tu búsqueda a películas que tuvieron reparto.
 
--not in //parametros que no esten dentro de esa clausula(genre masculinos)
--GENRE = 'F'

SELECT year, COUNT(DISTINCT m.id) AS femaleOnly
FROM movies m
WHERE m.id IN (
    SELECT DISTINCT r.movie_id
    FROM roles r
    WHERE r.actor_id IN (
        SELECT id
        FROM actors
        WHERE gender = 'F'
    )
)
GROUP BY year;
---------------

SELECT movies.year, COUNT(DISTINCT movie_id)
FROM actors 
JOIN roles
ON actors.id = roles.actor_id 
JOIN movies
ON movies.id = roles.movie_id
WHERE movies.id IN (
  SELECT movie_id
  FROM roles 
  WHERE actors.gender = 'F'
)
GROUP BY movies.year;






