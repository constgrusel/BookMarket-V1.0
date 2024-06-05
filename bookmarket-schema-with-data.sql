--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 15.6

-- Started on 2024-05-16 17:31:20

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
-- TOC entry 3421 (class 0 OID 0)
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
-- TOC entry 3422 (class 0 OID 0)
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
-- TOC entry 3423 (class 0 OID 0)
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
-- TOC entry 3424 (class 0 OID 0)
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
-- TOC entry 3425 (class 0 OID 0)
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
-- TOC entry 3426 (class 0 OID 0)
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
-- TOC entry 3427 (class 0 OID 0)
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
-- TOC entry 3411 (class 0 OID 16720)
-- Dependencies: 223
-- Data for Name: adres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adres (adres_id, adres_ilid, adres_text, adres_userid) FROM stdin;
2	34	ayazağa 	3
3	34	nato caddesi	4
4	2	gazi mahallesi	5
5	10	ışık üni	6
6	6	ankara üni	7
7	26	club	8
8	3	istanbul üni	9
9	37	kastamonu kalesi	10
10	57	odunpazarı çibörekçisi	11
11	10	yeşilyurt tesisleri	12
12	2	124124	14
13	26	msglkjsldkgsd	15
14	1	asfasf	16
15	8	hjfjkghjkg	17
\.


--
-- TOC entry 3413 (class 0 OID 16729)
-- Dependencies: 225
-- Data for Name: iller; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.iller (il_id, il_ad) FROM stdin;
1	Adana
2	Adıyaman
3	Afyonkarahisar
4	Ağrı
5	Amasya
6	Ankara
7	Antalya
8	Artvin
9	Aydın
10	Balıkesir
11	Bilecik
12	Bingöl
13	Bitlis
14	Bolu
15	Burdur
16	Bursa
17	Çanakkale
18	Çankırı
19	Çorum
20	Denizli
21	Diyarbakır
22	Edirne
23	Elazığ
24	Erzincan
25	Erzurum
26	Eskişehir
27	Gaziantep
28	Giresun
29	Gümüşhane
30	Hakkari
31	Hatay
32	Isparta
33	Mersin
34	İstanbul
35	İzmir
36	Kars
37	Kastamonu
38	Kayseri
39	Kırklareli
40	Kırşehir
41	Kocaeli
42	Konya
43	Kütahya
44	Malatya
45	Manisa
46	Kahramanmaraş
47	Mardin
48	Muğla
49	Muş
50	Nevşehir
51	Niğde
52	Ordu
53	Rize
54	Sakarya
55	Samsun
56	Siirt
57	Sinop
58	Sivas
59	Tekirdağ
60	Tokat
61	Trabzon
62	Tunceli
63	Şanlıurfa
64	Uşak
65	Van
66	Yozgat
67	Zonguldak
68	Aksaray
69	Bayburt
70	Karaman
71	Kırıkkale
72	Batman
73	Şırnak
74	Bartın
75	Ardahan
76	Iğdır
77	Yalova
78	Karabük
79	Kilis
80	Osmaniye
81	Düzce
\.


--
-- TOC entry 3405 (class 0 OID 16695)
-- Dependencies: 217
-- Data for Name: kitap; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kitap (kitap_id, kitap_ad, kitap_yazarid, kitap_turid, kitap_fiyat, kitap_stok) FROM stdin;
1	Beyaz Zambaklar Ülkesinde	1	10	55	100
2	Nil de ölüm	40	1	104	100
4	Otoptosçunun Galaksi Rehberi	46	13	234	100
5	Körlük	15	4	79	100
6	İçimizdeki Şeytan	18	3	175	100
7	Kızıl Elma	24	10	230	100
8	İki Oyun	31	7	340	100
9	Drakula	12	3	55	100
10	Medyum	39	12	189	100
11	Deniz Feneri	37	10	20	100
12	Ben	41	9	246	100
13	Aşk ve Mantık	42	5	219	100
14	Çoğunlukla Zararsız	46	13	79	100
15	İhtiyar Balıkçı	38	3	230	100
16	Aylak Adam	32	3	79	100
17	Bozkurtların Ölümü	23	10	169	100
18	Ubik	36	19	260	100
19	Yanardağın Altında	35	20	240	100
20	İki Süngü Arasında	33	11	75	100
22	Yaşama Sevinci	34	14	59	100
23	Enkheiridion	61	9	75	100
24	Kızgın Ova	51	7	120	100
25	Tonguç Işığı	59	3	40	100
26	Otuzların Kadını	58	5	130	100
27	Hanımın Çiftliği	57	3	340	100
28	Yalnız Dolambacı	56	15	270	100
29	Seviyorum Sizi	55	14	75	100
30	Yavaş Yavaş Ölürler	54	14	65	100
31	Ateşten Gömlek	53	3	349	100
32	Aura	52	7	150	100
33	Sonatina	50	3	260	100
34	İlahi Komedya	49	14	320	100
35	Kör Suikastçı	48	3	320	100
36	Kaybolan Masumiyet	47	3	259	100
37	Ölüm Sessiz Geldi	40	1	340	100
38	Cezmi	25	10	269	100
39	Tutunamayanlar	19	3	340	100
40	Savaş ve Barış	10	3	160	100
41	İnkılap Türküleri	21	14	60	100
42	Şato	9	20	240	100
43	Geri Gelen Mektup	23	14	239	100
44	Venedikte Cinayet	40	14	290	100
45	Jane Eyre	43	5	140	100
46	Ramayla Buluşma	27	19	240	100
47	1984	2	15	210	100
48	Sefiller	3	9	190	100
49	The Running Grave	6	11	123	100
50	Empati	13	3	180	100
51	Kar	16	11	189	100
52	Bozkurtların Dirilişi	23	10	310	100
53	Harry Potter	6	2	420	100
54	Kırmızı Pazartesi	17	4	320	100
97	Ruh Adam	23	10	190	99
55	Dava	7	15	210	100
56	Beyaz Geceler	4	20	230	100
57	Atlas Vazgeçiti	41	11	290	100
58	Azul	50	20	230	100
59	Murtaza	57	18	230	100
60	Gündökümü	58	5	180	100
61	Teneke	11	7	320	100
62	Yılanı öldürseler	11	3	210	100
63	Ortadirek	11	3	129	100
64	Çocukluğun sonu	27	19	210	100
65	Uzay Efsanesi	27	13	319	100
66	Küçük Prens	8	8	100	100
67	Gece Uçusu	8	8	75	100
68	Savaş Pilotu	8	8	99	100
69	Altın Işık	24	10	200	100
70	Türk Töresi	24	10	176	100
71	Daralma	2	20	200	100
72	Bir İdam	2	11	185	100
73	Burma Günleri	2	15	175	100
74	Piedra de Sol	56	3	290	100
75	Yanardağın Altında	35	3	210	100
76	Emma	42	5	120	100
77	İkna	42	5	340	100
78	Sanditon	42	5	60	100
79	Momo	14	6	210	100
80	Bitmeyecek Öykü	14	6	320	100
81	Alef	28	11	200	100
82	Babil Kütüphanesi	28	20	320	100
83	Atatürkçe	34	14	210	100
84	Düşsevi	34	14	60	100
85	Yaşama Sevinci	34	14	50	100
86	Yeşil Yol	39	4	349	100
87	Göz	39	4	190	100
88	Holly	39	12	200	100
89	Cinler	4	3	120	100
90	İnsancıklar	4	9	239	100
91	Linvite Arrive	29	14	234	100
92	Facing the Snow	29	14	190	100
93	Du Gongbu Collection	29	14	69	100
94	Ölüm Büyüsü	40	12	135	100
95	Cinayet İlanı	40	1	219	100
96	Dersimiz Cinayet	40	1	179	100
98	Deli Kurt	23	10	299	100
99	Z Vitamini	23	10	199	100
100	Diriliş	10	9	109	100
101	Çocukluk	10	20	79	100
102	Bitirim ikili	22	8	56	100
103	Levet iz Peşinde	22	8	69	100
104	Daga Tırmanan Kedi	22	8	70	100
105	Çocukluğun Sonu	27	13	189	100
106	Uzay Efsanesi	27	13	199	100
107	The Sential	27	13	129	100
108	İhtiyar Balıkçı	38	7	79	100
109	Paris Bir Şenliktir	38	7	99	100
3	Kan ve Gözyaşı	60	3	150	99
21	Zaman Artık Durmalı	26	9	180	99
110	Silahlara Veda	38	7	20	100
111	Null	13	3	189	100
112	Olasılıksız	13	3	160	100
113	Olasılıksız Empati	13	3	99	100
114	İdealist Öğretmen	1	20	199	100
115	Schule und Leben	1	20	119	100
116	Akzambaklar Ülkesinde	1	20	189	100
117	Zencilerim Mürsidi Kara Musa	1	20	209	100
118	inci	9	3	99	100
119	Gazap Üzümleri	9	3	79	100
120	Yukarı Mahalle	9	3	90	100
121	Al Midilli	9	3	89	100
122	Venedikte Ölüm	45	5	109	100
123	Büyülü Dağ	45	10	99	100
124	Yusuf ve Kardeşleri	45	10	129	100
125	Hanımın Çiftliği	57	3	199	100
126	Bereketli Topraklar Üzerinde	57	3	179	100
127	Gurbet Kuşları	57	3	209	100
128	Kutsal Dedektiflik Bürosu	46	13	289	100
129	Kuşkucu Somon	46	13	199	100
130	Çoğunlukla Zararsız	46	13	219	100
131	Türk isterse	21	10	289	100
132	İnklap Türküleri	21	10	189	100
133	Türk Bir Yanardağdır	21	10	219	100
134	İsaya Göre	15	9	99	100
135	Görmek	15	9	109	100
136	Kabil	15	10	89	100
137	Profesör	43	20	99	100
138	Shirley	43	5	119	100
139	Vilette	43	5	149	100
140	Öldürme Zamanı	44	4	99	100
141	Şirket	44	4	89	100
142	Masum Adam	44	4	109	100
143	Yargıcın Evi	12	12	199	100
144	Draculas Guest	12	12	219	100
145	Powers of Darkness	12	12	189	100
146	Anayurt Oteli	32	3	189	100
147	Canistan	32	3	229	100
148	Eylemci	32	7	189	100
149	Çift Alev	56	5	299	100
150	Adsız Bir Jude	47	3	329	100
\.


--
-- TOC entry 3415 (class 0 OID 16738)
-- Dependencies: 227
-- Data for Name: siparis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.siparis (siparis_id, siparis_userid, siparis_kitapid, siparis_date) FROM stdin;
17	3	97	2024-05-16 12:43:28.080336
18	3	3	2024-05-16 12:44:11.27379
19	17	21	2024-05-16 16:55:39.718971
\.


--
-- TOC entry 3407 (class 0 OID 16704)
-- Dependencies: 219
-- Data for Name: turler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turler (tur_id, tur_ad) FROM stdin;
1	Polisiye
2	Macera
3	Roman
4	Korku
5	Romantik
6	Fantastik
7	Kısa Roman
8	Çocuk Kitabı
9	Felsefe
10	Tarih
11	Edebiyat
12	Gothic Korku
13	Bilimkurgu
14	Şiir
15	Distopya
16	Dram
17	Mizah
18	Biyografi
19	Bilim
20	Klasik
\.


--
-- TOC entry 3403 (class 0 OID 16684)
-- Dependencies: 215
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, user_ad, user_soyad, user_pass, user_mail, user_dgtarih, user_tel, user_rutbe) FROM stdin;
3	sukru	Şükrü	Bakırcı	e10adc3949ba59abbe56e057f20f883e	sukru@bookmarket.com	2002-11-26	05303730237	1
4	reco	Recai	Kuşkaya	827ccb0eea8a706c4c34a16891f84e7b	reco@bookmarket.com	2024-05-13	05252235235	0
5	hasan	Hasan	Hüseyin	827ccb0eea8a706c4c34a16891f84e7b	hasan@bookmarket.com	1994-06-23	05124124124	0
6	tugcesen	Tuğçe	Şen	827ccb0eea8a706c4c34a16891f84e7b	tugcesen@bookmarket.com	2001-07-13	05243523523	0
7	yaso	Yasemin	Kılınç	827ccb0eea8a706c4c34a16891f84e7b	yaso@bookmarket.com	2003-01-04	05235234234	0
8	mertarukan	Mert	Arukan	827ccb0eea8a706c4c34a16891f84e7b	mertarukan@bookmarket.com	2002-07-12	05252523523	0
9	mikbal	İkbal	Güven	fcea920f7412b5da7be0cf42b8c93759	mikbal@bookmarket.com	2004-06-24	05235235235	0
10	bilge	Bilge	Çakmakoğlu	c33367701511b4f6020ec61ded352059	bilge@bookmarket.com	2002-07-18	05252342342	0
11	sarızeynep	Zeynep	Sarı	e807f1fcf82d132f9bb018ca6738a19f	sarızeynep@bookmarket.com	2004-06-17	05234234234	0
12	esmacakir	Esma	Çakır	e10adc3949ba59abbe56e057f20f883e	esma@bookmarket.com	2004-06-16	05239523984	0
14	asfasf	asfasf	asfasf	3f2cf36a0963cf127ce8b5f1eb91a447	asfasf	2024-05-15	12412412412	0
15	sehercam	Seher	Çam	e10adc3949ba59abbe56e057f20f883e	sehercam@bookmarket.com	2000-05-21	05129487192	0
16	hsddafasfasgasf	asfasf	sfasf	f38ded7f8810680d849767903074bae3	sfasf	2024-05-16	12515125123	0
17	lale	Lale	Meran	827ccb0eea8a706c4c34a16891f84e7b	lale@bookmarket.com	2024-05-16	05423982935	0
\.


--
-- TOC entry 3409 (class 0 OID 16711)
-- Dependencies: 221
-- Data for Name: yazar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yazar (yazar_id, yazar_ad, yazar_bio) FROM stdin;
44	John Grisham 	Amerikalı siyasetçi avukat ve yazar
45	Thomass Mann	1875 doğumlu Alman nobel ödüllü yazar
46	Douglas Adams	İngiliz bilimkurgu yazarı 
47	Thomas Hardy	1840 doğumlu İngiliz yazar ve şair
48	Margaret Atwood	Kanadalı feminist yazar şair eleştirmen
49	Dante Alighieri	1265 doğumlu İtalyan şair ve yazar 
50	Ruben Dario 	1867 doğumludur İspanyalı yazar
51	Juan Rulfo	1917 doğumlu Meksikalı kısa roman yazarı
52	Carlos Fuentes	1928 doğumlu Meksikalı yazar
53	Halide Edip Adıvar	Türk yazar siyasetçi akademisyen ve öğretmen
54	Pablo Neruda	1904 doğumlu Şilili yazar ve şair
55	Aleksandr Puşkin	1799 doğumlu Rus şair ve yazardır
56	Octavio Paz	1914 doğumlu meksikalı yazar ve diplomat
57	Orhan Kemal	Türk roman ve oyun yazarıdır
58	Tomris Uyar	1941 doğumlu Türk yazar çevirmendir
59	Fikret Madaralı	1908 doğumlu Türk öğretmen yazar
60	Behzat Ay	1936 doğumlu Türk yazar ve öğretmendir
61	Epictetus	Stoacı filozof
1	Grigory Petrov	1866 doğumlu Rus yazar.
2	George Orwell	1903 doğumlu Hint yazar.
3	Victor Hugo	1802 doğumlu Fransız yazar.
4	Fyodor Dostoyevski	1821 doğumlu Rus yazar
5	Paulo Coelho	Brezilyalı şarkı ve roman yazarı
6	J.K. Rowling	Harry Potter serisinin yazarı
7	Franz Kafka	Boheyamlı roman ve hikaye yazarı
8	Antoine de Saint-Exupéry	Çocuk Kitabı
9	John Steinbeck	Amerikalı gerçekçi yazar
10	Leo Tolstoy	1828 doğumlu Rus yazar ve asker
11	Yaşar Kemal	Türk yazar şair ve aktivist
12	Bram Stoker	1847 doğumlu İrlandalı yazar
13	Adam Fawer	1970 doğumlu Amerikalı yazar
14	Michael Ende	Alman fantastik çocuk yazarı
15	Jose Saramago	1922 doğumlu Portekizli yazar
16	Orhan Pamuk	Yazar ve 2006 nobel ödülü sahibi
17	Gabriel García Márquez	Nobel ödüllü kolombiyalı yazar
18	Sabahattin Ali	1907 doğumlu Türk yazar ve şair
19	Oğuz Atay	Türk roman öykü ve oyun yazarı
20	Antoine de Saint-Exupéry	1900 doğumlu Fransız pilot yazar
21	İhsan Hınçer	1916 doğumlu Türk yazar ve halk bilimci
22	Mustafa Orakçı	1979 doğumlu çocuk kitap yazarı
23	Hüseyin Nihal Atsız	1905 doğumlu türkolog ve tarihçi
24	Ziya Gökalp	Türk yazar şair ve siyasetçidir
25	Namık Kemal	1840 doğumlu Türk yazar
26	Aldous Huxley	1894 doğumlu amerikalı yazar
27	Arthur CLarke 	1917 Doğumlu mucit ve yazar
28	Lorge Luis	Arjantinli deneme yazarı ve şair
29	Du Fu	 712 doğumludur döneminin önemli şairidir
30	Robert Hayden	Amerikalı şair ve yazar.
31	Henrik ibsen	1828 doğumlu Norveçli yazar ve şair
32	Yusuf Atılgan	1921 doğumlu Türk yazar ve öğretmen
33	Aka Gündüz	Türk yazar gazeteci ve siyasetçidir
34	Cahit Obruk	Türk şair edebiyatçı ve öykücü
35	Malcolm Lowry	1909 doğumlu İngiliz yazar ve şair
36	Philip K. Dick	1928 doğumlu Amerikalı yazar
37	Virginia Woolf	İngiliz feminist yazar ve eleştirmen
38	Ernest Hemingway	Amerikalı hikaye yazarı ve gazeteci
39	Stephen King	1947 doğumlu korku doğaüstü vb türlerde yazar
40	Agatha Christie	İngiliz yazar 1890 doğumlu
41	Ayn rad	1905 doğumlu  Rus yazar
42	Jane Austen	19. yy da yaşamış romantik tür de yazardır
43	Charlotte Bronte	1816 doğumlu ingiliz yazar 
\.


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 222
-- Name: adres_adres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adres_adres_id_seq', 15, true);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 224
-- Name: iller_il_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.iller_il_id_seq', 1, false);


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 216
-- Name: kitap_kitap_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kitap_kitap_id_seq', 1, false);


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 226
-- Name: siparis_siparis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparis_siparis_id_seq', 19, true);


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 218
-- Name: turler_tur_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turler_tur_id_seq', 1, false);


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 214
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 17, true);


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 220
-- Name: yazar_yazar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.yazar_yazar_id_seq', 1, false);


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


-- Completed on 2024-05-16 17:31:23

--
-- PostgreSQL database dump complete
--

