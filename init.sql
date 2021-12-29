--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3
-- Dumped by pg_dump version 13.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: export(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.export(game_name character varying DEFAULT NULL::character varying, achievement_name character varying DEFAULT NULL::character varying, category_name character varying DEFAULT NULL::character varying, downloadable_content_name character varying DEFAULT NULL::character varying)
    LANGUAGE sql
    AS $$
 with 
 game(id) as (
	 insert into games(name)
	 select game_name where game_name is not null and game_name != ''
	 on conflict (name) do update set name=excluded.name returning id
 ),
 category(id) as (
	 insert into categories(name)
	 select category_name where category_name is not null and category_name != ''
	 on conflict (name) do update set name=excluded.name returning id
 ),
 game_category as (
	 insert into games_categories(game_id, category_id)
	 select game.id, category.id 
	 from game, category where game.id is not null and category.id is not null
	 on conflict on constraint games_categories_pkey do nothing
 ),
 achievement as (
	 insert into achievements(name, game_id)
	 select achievement_name, game.id from game where achievement_name is not null and achievement_name != ''
	 on conflict (name) do nothing
 ),

 downloadable_content as (
	 insert into downloadable_contents(name, game_id)
	 select downloadable_content_name, game.id from game where downloadable_content_name is not null and downloadable_content_name != ''
	 on conflict (name) do nothing
 )
 select 1;
$$;


ALTER PROCEDURE public.export(game_name character varying, achievement_name character varying, category_name character varying, downloadable_content_name character varying) OWNER TO postgres;

--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.achievements_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievements (
    id integer DEFAULT nextval('public.achievements_id_seq'::regclass) NOT NULL,
    name character varying(50) NOT NULL,
    game_id integer NOT NULL
);


ALTER TABLE public.achievements OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer DEFAULT nextval('public.categories_id_seq'::regclass) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: downloadable_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.downloadable_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.downloadable_contents_id_seq OWNER TO postgres;

--
-- Name: downloadable_contents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.downloadable_contents (
    id integer DEFAULT nextval('public.downloadable_contents_id_seq'::regclass) NOT NULL,
    name character varying(50) NOT NULL,
    game_id integer NOT NULL
);


ALTER TABLE public.downloadable_contents OWNER TO postgres;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_id_seq OWNER TO postgres;

--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id integer DEFAULT nextval('public.games_id_seq'::regclass) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: games_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_categories (
    game_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE public.games_categories OWNER TO postgres;

--
-- Name: achievements achievements_name_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_name_uniq UNIQUE (name);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_uniq UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: downloadable_contents downloadable_contents_name_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.downloadable_contents
    ADD CONSTRAINT downloadable_contents_name_uniq UNIQUE (name);


--
-- Name: downloadable_contents downloadable_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.downloadable_contents
    ADD CONSTRAINT downloadable_contents_pkey PRIMARY KEY (id);


--
-- Name: games_categories games_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_categories
    ADD CONSTRAINT games_categories_pkey PRIMARY KEY (game_id, category_id);


--
-- Name: games games_name_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_name_uniq UNIQUE (name);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: achievements achievements_games_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_games_id_foreign FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- Name: downloadable_contents downloadable_contents_game_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.downloadable_contents
    ADD CONSTRAINT downloadable_contents_game_id_foreign FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- Name: games_categories games_categories_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_categories
    ADD CONSTRAINT games_categories_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: games_categories games_categories_game_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_categories
    ADD CONSTRAINT games_categories_game_id_foreign FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- PostgreSQL database dump complete
--

