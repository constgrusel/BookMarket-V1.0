--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 15.6

-- Started on 2024-05-16 17:29:47

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
-- TOC entry 230 (class 1255 OID 16940)
-- Name: decrease_book_stock(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrease_book_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE kitap
    SET kitap_stok = kitap_stok - 1
    WHERE kitap_id = NEW.siparis_kitapid;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.decrease_book_stock() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16861)
-- Name: kitap_tur_yazar_getir(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kitap_tur_yazar_getir(p_tur_id integer DEFAULT NULL::integer, p_yazar_id integer DEFAULT NULL::integer) RETURNS TABLE(kitap_id integer, kitap_ad character varying, kitap_yazarid integer, kitap_turid integer, kitap_fiyat integer, kitap_stok integer, tur_id integer, tur_ad character varying, yazar_id integer, yazar_ad character varying, yazar_bio character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        k.kitap_id,
        k.kitap_ad,
        k.kitap_yazarid,
        k.kitap_turid,
        k.kitap_fiyat,
        k.kitap_stok,
        t.tur_id,
        t.tur_ad,
        y.yazar_id,
        y.yazar_ad,
        y.yazar_bio
    FROM 
        kitap k
    JOIN
        turler t ON k.kitap_turid = t.tur_id
    JOIN
        yazar y ON k.kitap_yazarid = y.yazar_id
    WHERE 
        (p_tur_id IS NULL OR k.kitap_turid = p_tur_id)
        AND (p_yazar_id IS NULL OR k.kitap_yazarid = p_yazar_id);
END;
$$;


ALTER FUNCTION public.kitap_tur_yazar_getir(p_tur_id integer, p_yazar_id integer) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16933)
-- Name: search_books(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_books(search_text character varying) RETURNS TABLE(kitap_id integer, kitap_ad character varying, yazar_ad character varying, tur_id integer, tur_ad character varying, kitap_fiyat integer, kitap_stok integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.kitap_id,
        k.kitap_ad,
        y.yazar_ad,
        t.tur_id,
        t.tur_ad,
        k.kitap_fiyat,
        k.kitap_stok
    FROM
        kitap k
    JOIN
        yazar y ON k.kitap_yazarid = y.yazar_id
    JOIN
        turler t ON k.kitap_turid = t.tur_id
    WHERE
        LOWER(k.kitap_ad) LIKE '%' || LOWER(search_text) || '%' OR
        LOWER(y.yazar_ad) LIKE '%' || LOWER(search_text) || '%' OR
        LOWER(t.tur_ad) LIKE '%' || LOWER(search_text) || '%';
END;
$$;


ALTER FUNCTION public.search_books(search_text character varying) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 24654)
-- Name: search_orders(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_orders(user_id integer, search_text character varying) RETURNS TABLE(siparis_id integer, kitap_id integer, kitap_ad character varying, yazar_ad character varying, kitap_fiyat integer, kitap_stok integer, siparis_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.siparis_id,
        k.kitap_id,
        k.kitap_ad,
        y.yazar_ad,
        k.kitap_fiyat,
        k.kitap_stok,
        s.siparis_date
    FROM
        siparis s
    JOIN
        kitap k ON s.siparis_kitapid = k.kitap_id
    JOIN
        yazar y ON k.kitap_yazarid = y.yazar_id
    WHERE
        s.siparis_userid = user_id AND
        (LOWER(k.kitap_ad) LIKE '%' || LOWER(search_text) || '%' OR
        LOWER(y.yazar_ad) LIKE '%' || LOWER(search_text) || '%');
END;
$$;


ALTER FUNCTION public.search_orders(user_id integer, search_text character varying) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16925)
-- Name: set_siparis_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_siparis_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.siparis_date = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_siparis_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 223 (class 1259 OID 16720)
-- Name: adres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adres (
    adres_id integer NOT NULL,
    adres_ilid integer NOT NULL,
    adres_text character varying NOT NULL,
    adres_userid integer NOT NULL
);


ALTER TABLE public.adres OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16719)
-- Name: adres_adres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adres_adres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adres_adres_id_seq OWNER TO postgres;

--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 222
-- Name: adres_adres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adres_adres_id_seq OWNED BY public.adres.adres_id;


--
-- TOC entry 225 (class 1259 OID 16729)
-- Name: iller; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iller (
    il_id integer NOT NULL,
    il_ad character varying NOT NULL
);


ALTER TABLE public.iller OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16728)
-- Name: iller_il_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.iller_il_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.iller_il_id_seq OWNER TO postgres;

--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 224
-- Name: iller_il_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.iller_il_id_seq OWNED BY public.iller.il_id;


--
-- TOC entry 217 (class 1259 OID 16695)
-- Name: kitap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kitap (
    kitap_id integer NOT NULL,
    kitap_ad character varying NOT NULL,
    kitap_yazarid integer NOT NULL,
    kitap_turid integer NOT NULL,
    kitap_fiyat integer NOT NULL,
    kitap_stok integer NOT NULL,
    CONSTRAINT kitap_stok_positive CHECK ((kitap_stok >= 0))
);


ALTER TABLE public.kitap OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16694)
-- Name: kitap_kitap_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kitap_kitap_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kitap_kitap_id_seq OWNER TO postgres;

--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 216
-- Name: kitap_kitap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kitap_kitap_id_seq OWNED BY public.kitap.kitap_id;


--
-- TOC entry 229 (class 1259 OID 24659)
-- Name: locationinfo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.locationinfo AS
 SELECT i.il_id,
    i.il_ad,
    a.adres_text,
    a.adres_userid,
    a.adres_ilid
   FROM (public.iller i
     JOIN public.adres a ON ((i.il_id = a.adres_ilid)))
  ORDER BY i.il_ad;


ALTER TABLE public.locationinfo OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16738)
-- Name: siparis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparis (
    siparis_id integer NOT NULL,
    siparis_userid integer NOT NULL,
    siparis_kitapid integer NOT NULL,
    siparis_date timestamp without time zone NOT NULL
);


ALTER TABLE public.siparis OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16737)
-- Name: siparis_siparis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparis_siparis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparis_siparis_id_seq OWNER TO postgres;

--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 226
-- Name: siparis_siparis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparis_siparis_id_seq OWNED BY public.siparis.siparis_id;


--
-- TOC entry 219 (class 1259 OID 16704)
-- Name: turler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turler (
    tur_id integer NOT NULL,
    tur_ad character varying NOT NULL
);


ALTER TABLE public.turler OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16703)
-- Name: turler_tur_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.turler_tur_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.turler_tur_id_seq OWNER TO postgres;

--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 218
-- Name: turler_tur_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.turler_tur_id_seq OWNED BY public.turler.tur_id;


--
-- TOC entry 215 (class 1259 OID 16684)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying NOT NULL,
    user_ad character varying NOT NULL,
    user_soyad character varying NOT NULL,
    user_pass character varying NOT NULL,
    user_mail character varying NOT NULL,
    user_dgtarih date NOT NULL,
    user_tel character varying NOT NULL,
    user_rutbe integer DEFAULT 0,
    CONSTRAINT check_user_tel_length CHECK ((char_length((user_tel)::text) = 11)),
    CONSTRAINT users_user_rutbe_check CHECK ((user_rutbe = ANY (ARRAY[0, 1])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24629)
-- Name: user_details_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_details_view AS
 SELECT users.user_id,
    users.username,
    users.user_ad,
    users.user_soyad,
    users.user_tel,
    users.user_mail,
    users.user_rutbe
   FROM public.users;


ALTER TABLE public.user_details_view OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16683)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 214
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 221 (class 1259 OID 16711)
-- Name: yazar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yazar (
    yazar_id integer NOT NULL,
    yazar_ad character varying NOT NULL,
    yazar_bio character varying NOT NULL
);


ALTER TABLE public.yazar OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16710)
-- Name: yazar_yazar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.yazar_yazar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.yazar_yazar_id_seq OWNER TO postgres;

--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 220
-- Name: yazar_yazar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.yazar_yazar_id_seq OWNED BY public.yazar.yazar_id;


--
-- TOC entry 3221 (class 2604 OID 16723)
-- Name: adres adres_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres ALTER COLUMN adres_id SET DEFAULT nextval('public.adres_adres_id_seq'::regclass);


--
-- TOC entry 3222 (class 2604 OID 16732)
-- Name: iller il_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iller ALTER COLUMN il_id SET DEFAULT nextval('public.iller_il_id_seq'::regclass);


--
-- TOC entry 3218 (class 2604 OID 16698)
-- Name: kitap kitap_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap ALTER COLUMN kitap_id SET DEFAULT nextval('public.kitap_kitap_id_seq'::regclass);


--
-- TOC entry 3223 (class 2604 OID 16741)
-- Name: siparis siparis_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis ALTER COLUMN siparis_id SET DEFAULT nextval('public.siparis_siparis_id_seq'::regclass);


--
-- TOC entry 3219 (class 2604 OID 16707)
-- Name: turler tur_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turler ALTER COLUMN tur_id SET DEFAULT nextval('public.turler_tur_id_seq'::regclass);


--
-- TOC entry 3216 (class 2604 OID 16687)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 3220 (class 2604 OID 16714)
-- Name: yazar yazar_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yazar ALTER COLUMN yazar_id SET DEFAULT nextval('public.yazar_yazar_id_seq'::regclass);


--
-- TOC entry 3240 (class 2606 OID 16727)
-- Name: adres adres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres
    ADD CONSTRAINT adres_pkey PRIMARY KEY (adres_id);


--
-- TOC entry 3243 (class 2606 OID 16736)
-- Name: iller iller_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iller
    ADD CONSTRAINT iller_pkey PRIMARY KEY (il_id);


--
-- TOC entry 3234 (class 2606 OID 16702)
-- Name: kitap kitap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT kitap_pkey PRIMARY KEY (kitap_id);


--
-- TOC entry 3245 (class 2606 OID 16744)
-- Name: siparis siparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_pkey PRIMARY KEY (siparis_id);


--
-- TOC entry 3236 (class 2606 OID 16709)
-- Name: turler turler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turler
    ADD CONSTRAINT turler_pkey PRIMARY KEY (tur_id);


--
-- TOC entry 3228 (class 2606 OID 16928)
-- Name: users unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 3230 (class 2606 OID 16691)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3232 (class 2606 OID 16693)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3238 (class 2606 OID 16718)
-- Name: yazar yazar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yazar
    ADD CONSTRAINT yazar_pkey PRIMARY KEY (yazar_id);


--
-- TOC entry 3241 (class 1259 OID 24615)
-- Name: fki_adres_useridfkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_adres_useridfkey ON public.adres USING btree (adres_userid);


--
-- TOC entry 3255 (class 2620 OID 16926)
-- Name: siparis set_siparis_date_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_siparis_date_trigger BEFORE INSERT ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.set_siparis_date();


--
-- TOC entry 3256 (class 2620 OID 16941)
-- Name: siparis siparis_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparis_insert_trigger AFTER INSERT ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.decrease_book_stock();


--
-- TOC entry 3257 (class 2620 OID 24597)
-- Name: siparis trigger_set_siparis_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_set_siparis_date BEFORE INSERT ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.set_siparis_date();


--
-- TOC entry 3251 (class 2606 OID 16754)
-- Name: adres adres_adres_ilid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres
    ADD CONSTRAINT adres_adres_ilid_fkey FOREIGN KEY (adres_ilid) REFERENCES public.iller(il_id);


--
-- TOC entry 3252 (class 2606 OID 24610)
-- Name: adres adres_useridfkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres
    ADD CONSTRAINT adres_useridfkey FOREIGN KEY (adres_userid) REFERENCES public.users(user_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3246 (class 2606 OID 16912)
-- Name: kitap fk_kitap_turid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT fk_kitap_turid FOREIGN KEY (kitap_turid) REFERENCES public.turler(tur_id) ON DELETE CASCADE;


--
-- TOC entry 3247 (class 2606 OID 16917)
-- Name: kitap fk_kitap_yazarid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT fk_kitap_yazarid FOREIGN KEY (kitap_yazarid) REFERENCES public.yazar(yazar_id) ON DELETE CASCADE;


--
-- TOC entry 3248 (class 2606 OID 24633)
-- Name: kitap kitap_kitap_turid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT kitap_kitap_turid_fkey FOREIGN KEY (kitap_turid) REFERENCES public.turler(tur_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3249 (class 2606 OID 24621)
-- Name: kitap kitap_kitap_yazarid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT kitap_kitap_yazarid_fkey FOREIGN KEY (kitap_yazarid) REFERENCES public.yazar(yazar_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3250 (class 2606 OID 24616)
-- Name: kitap kitap_yazarid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kitap
    ADD CONSTRAINT kitap_yazarid_fkey FOREIGN KEY (kitap_yazarid) REFERENCES public.yazar(yazar_id) ON DELETE CASCADE;


--
-- TOC entry 3253 (class 2606 OID 24639)
-- Name: siparis siparis_siparis_kitapid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_siparis_kitapid_fkey FOREIGN KEY (siparis_kitapid) REFERENCES public.kitap(kitap_id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3254 (class 2606 OID 24605)
-- Name: siparis siparis_siparis_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_siparis_userid_fkey FOREIGN KEY (siparis_userid) REFERENCES public.users(user_id) ON DELETE CASCADE;


-- Completed on 2024-05-16 17:29:49

--
-- PostgreSQL database dump complete
--

