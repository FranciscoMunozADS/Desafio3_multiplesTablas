--  CREAR BASE DE DATOS

CREATE DATABASE desafio3_francisco_munoz_420;

	-- conectar a database (este comando solo funciona en SQL Shell, no en pgAdmin)

		 \c desafio3_francisco_munoz_420;

--  CREAR TABLA USUARIOS

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(50) NOT NULL
);

SELECT * FROM usuarios;


--  CREAR TABLA POSTS

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW(),
    destacado BOOLEAN DEFAULT FALSE,
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL
);

SELECT * FROM posts;


--  CREAR TABLA COMENTARIOS

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE
);

SELECT * FROM comentarios;

-- INSERCIÓN DE DATOS

-- INSERTAR usuarios

INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
('admin@email.com', 'Admin', 'User', 'administrador'),
('user1@email.com', 'Usuario1', 'Apellido1', 'usuario'),
('user2@email.com', 'Usuario2', 'Apellido2', 'usuario'),
('user3@email.com', 'Usuario3', 'Apellido3', 'usuario'),
('user4@email.com', 'Usuario4', 'Apellido4', 'usuario');


-- INSERTAR posts

INSERT INTO posts (titulo, contenido, usuario_id, destacado) VALUES
('Post del Admin 1', 'Contenido del primer post del admin.', 1, TRUE),
('Post del Admin 2', 'Contenido del segundo post del admin.', 1, FALSE),
('Post de Usuario1', 'Contenido del post de usuario 1.', 2, FALSE),
('Post de Usuario2', 'Contenido del post de usuario 2.', 3, TRUE),
('Post sin usuario', 'Este post no tiene usuario asignado.', NULL, FALSE);


-- INSERTAR comentarios

INSERT INTO comentarios (contenido, usuario_id, post_id) VALUES
('Comentario de Admin en Post 1', 1, 1),
('Comentario de User1 en Post 1', 2, 1),
('Comentario de User2 en Post 1', 3, 1),
('Comentario de Admin en Post 2', 1, 2),
('Comentario de User1 en Post 2', 2, 2);



-- REQUERIMIENTOS 

-- 1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido.

-- creadas anteriormente:
SELECT * FROM usuarios;
SELECT * FROM posts;
SELECT * FROM comentarios;

-- 2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post.

SELECT u.nombre, u.email, p.titulo, p.contenido
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id;

-- 3. Muestra el id, título y contenido de los posts de los administradores.
-- a. El administrador puede ser cualquier id.

SELECT p.id, p.titulo, p.contenido
FROM posts p
JOIN usuarios u ON p.usuario_id = u.id
WHERE u.rol = 'administrador';

-- 4. Cuenta la cantidad de posts de cada usuario.
-- a. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.

SELECT u.id, u.email, COUNT(p.id) AS cantidad_posts
FROM usuarios u
LEFT JOIN posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- 5. Muestra el email del usuario que ha creado más posts.
-- a. Aquí la tabla resultante tiene un único registro y muestra solo el email.

SELECT u.email
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id
GROUP BY u.email
ORDER BY COUNT(p.id) DESC
LIMIT 1;

-- 6. Muestra la fecha del último post de cada usuario.

SELECT usuario_id, MAX(fecha_creacion) AS ultima_fecha_post
FROM posts
GROUP BY usuario_id;

-- 7. Muestra el título y contenido del post (artículo) con más comentarios.

SELECT p.titulo, p.contenido
FROM posts p
JOIN comentarios c ON p.id = c.post_id
GROUP BY p.id
ORDER BY COUNT(c.id) DESC
LIMIT 1;

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.

SELECT p.titulo, p.contenido, c.contenido AS comentario, u.email
FROM posts p
JOIN comentarios c ON p.id = c.post_id
JOIN usuarios u ON c.usuario_id = u.id;

-- 9. Muestra el contenido del último comentario de cada usuario.

SELECT DISTINCT ON (c.usuario_id) c.usuario_id, c.contenido
FROM comentarios c
ORDER BY c.usuario_id, c.fecha_creacion DESC;

/* 
hay otra manera usando where y max(fecha_creacion), pero si hay mas de un comentario con la misma fecha compartirá todos.
con distinct se filtra por sólo el último
*/

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario.

SELECT u.email
FROM usuarios u
LEFT JOIN comentarios c ON u.id = c.usuario_id
WHERE c.id IS NULL;

-- a última hora leí que habia que usar HAVING

SELECT u.email
FROM usuarios u
LEFT JOIN comentarios c ON u.id = c.usuario_id
GROUP BY u.id
HAVING COUNT(c.id) = 0;

