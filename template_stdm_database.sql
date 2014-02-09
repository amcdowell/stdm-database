--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.4
-- Dumped by pg_dump version 9.2.4
-- Started on 2014-02-09 11:16:33

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 9 (class 2615 OID 17673)
-- Name: stdm_public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stdm_public;


ALTER SCHEMA stdm_public OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 17509)
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- TOC entry 322 (class 3079 OID 11727)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 322
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 324 (class 3079 OID 16394)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 324
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 323 (class 3079 OID 17510)
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 323
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET search_path = public, pg_catalog;

--
-- TOC entry 1743 (class 1247 OID 17676)
-- Name: breakpoint; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE breakpoint AS (
	func oid,
	linenumber integer,
	targetname text
);


ALTER TYPE public.breakpoint OWNER TO postgres;

--
-- TOC entry 1746 (class 1247 OID 17679)
-- Name: frame; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE frame AS (
	level integer,
	targetname text,
	func oid,
	linenumber integer,
	args text
);


ALTER TYPE public.frame OWNER TO postgres;

--
-- TOC entry 1749 (class 1247 OID 17682)
-- Name: proxyinfo; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE proxyinfo AS (
	serverversionstr text,
	serverversionnum integer,
	proxyapiver integer,
	serverprocessid integer
);


ALTER TYPE public.proxyinfo OWNER TO postgres;

--
-- TOC entry 1752 (class 1247 OID 17685)
-- Name: targetinfo; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE targetinfo AS (
	target oid,
	schema oid,
	nargs integer,
	argtypes oidvector,
	targetname name,
	argmodes "char"[],
	argnames text[],
	targetlang oid,
	fqname text,
	returnsset boolean,
	returntype oid
);


ALTER TYPE public.targetinfo OWNER TO postgres;

--
-- TOC entry 1755 (class 1247 OID 17688)
-- Name: var; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE var AS (
	name text,
	varclass character(1),
	linenumber integer,
	isunique boolean,
	isconst boolean,
	isnotnull boolean,
	dtype oid,
	value text
);


ALTER TYPE public.var OWNER TO postgres;

--
-- TOC entry 1310 (class 1255 OID 17689)
-- Name: generate_guid(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION generate_guid(character varying, character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$ 
 
/* This function generates globally unique identifyers
   based on parameters table_name and sequence_name
*/
DECLARE
   active_database varchar;
   active_user varchar;
   active_client_ip_address varchar;
   active_table varchar;
   active_sequence varchar;
   active_timestamp varchar = to_char(now(),'YYYYMMDDHH24MISS');
   qry_statement varchar ;
   sequence_number varchar;
   guid varchar;
BEGIN
   active_database = current_database();
   active_user = current_user;
   active_client_ip_address = inet_client_addr();
   active_table = $1;
   active_sequence = $2;
   qry_statement = 'select (nextval('''||active_sequence||'''))';
   EXECUTE qry_statement INTO sequence_number;
   guid = '{'||md5(active_database||active_user||active_client_ip_address||active_table||active_sequence||sequence_number||active_timestamp)||'}';    
return guid;
END;
 
 $_$;


ALTER FUNCTION public.generate_guid(character varying, character varying) OWNER TO postgres;

--
-- TOC entry 1311 (class 1255 OID 17690)
-- Name: pc_chartoint(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pc_chartoint(chartoconvert character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	select case when trim($1) similar to '[0-9]+'
	then cast(trim($1) as integer)
	else null end;
	$_$;


ALTER FUNCTION public.pc_chartoint(chartoconvert character varying) OWNER TO postgres;

--
-- TOC entry 1312 (class 1255 OID 17693)
-- Name: valid_user(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION valid_user(text, text) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $_$
SELECT EXISTS(
SELECT * FROM pg_shadow
WHERE usename = $1 AND passwd = 'md5' || MD5($2 || $1)
);
$_$;


ALTER FUNCTION public.valid_user(text, text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 17716)
-- Name: spatial_unit; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit (
    gid integer NOT NULL,
    spatial_unit_type character varying(50),
    project_name character varying(100),
    use_type character varying(50),
    polygon geometry,
    point geometry,
    type_name character varying(500),
    line geometry,
    the_geometry geometry,
    admin_spatial_unit_set_gid integer,
    identity character varying(50),
    house_type character varying(50),
    structure_length integer DEFAULT 0,
    structure_width integer DEFAULT 0,
    total_househld_no integer DEFAULT 0,
    other_use_type character varying(50),
    perimeter integer,
    house_shape character varying(50),
    land_owner character varying(100),
    CONSTRAINT enforce_dims_line CHECK ((st_ndims(line) = 2)),
    CONSTRAINT enforce_dims_point CHECK ((st_ndims(point) = 2)),
    CONSTRAINT enforce_dims_polygon CHECK ((st_ndims(polygon) = 2)),
    CONSTRAINT enforce_dims_the_geometry CHECK ((st_ndims(the_geometry) = 2)),
    CONSTRAINT enforce_geotype_line CHECK (((geometrytype(line) = 'LINESTRING'::text) OR (line IS NULL))),
    CONSTRAINT enforce_geotype_point CHECK (((geometrytype(point) = 'POINT'::text) OR (point IS NULL))),
    CONSTRAINT enforce_geotype_the_geometry CHECK (((geometrytype(the_geometry) = 'GEOMETRYCOLLECTION'::text) OR (the_geometry IS NULL))),
    CONSTRAINT enforce_srid_line CHECK ((st_srid(line) = 32636)),
    CONSTRAINT enforce_srid_point CHECK ((st_srid(point) = 32636)),
    CONSTRAINT enforce_srid_polygon CHECK ((st_srid(polygon) = 32636)),
    CONSTRAINT enforce_srid_the_geometry CHECK ((st_srid(the_geometry) = 32636))
);


ALTER TABLE public.spatial_unit OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 17735)
-- Name: Spatial Use Type Stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "Spatial Use Type Stats" AS
    SELECT DISTINCT spatial_unit.use_type, count(*) AS count FROM spatial_unit GROUP BY spatial_unit.use_type ORDER BY count(*) DESC LIMIT 8;


ALTER TABLE public."Spatial Use Type Stats" OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 17739)
-- Name: admin_spatial_unit_set; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE admin_spatial_unit_set (
    name character varying(50) NOT NULL,
    hierarchy_level integer NOT NULL,
    area_id character varying(35),
    gid integer NOT NULL,
    part_of_asus_gid integer,
    code_name character varying(10),
    date_started timestamp without time zone,
    date_finished timestamp without time zone
);


ALTER TABLE public.admin_spatial_unit_set OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 17742)
-- Name: admin_spatial_unit_set_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE admin_spatial_unit_set_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_spatial_unit_set_gid_seq OWNER TO postgres;

--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 199
-- Name: admin_spatial_unit_set_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE admin_spatial_unit_set_gid_seq OWNED BY admin_spatial_unit_set.gid;


--
-- TOC entry 200 (class 1259 OID 17744)
-- Name: area_profile; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE area_profile (
    gid integer NOT NULL,
    year_established timestamp without time zone NOT NULL,
    status_of_slum character varying(25) NOT NULL,
    natural_risk character varying(35),
    man_made_threats character varying(35),
    natural_risks_type character varying(100),
    man_made_risk_type character varying(100),
    poverty_level character varying(25),
    total_population integer,
    total_household integer,
    common_structures character varying(25),
    disputes character varying(25),
    with_whom character varying(50),
    comments character varying(200),
    history character varying(250),
    area_id integer,
    population_id integer,
    profiler_id integer
);


ALTER TABLE public.area_profile OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 17750)
-- Name: area_profile_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE area_profile_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.area_profile_gid_seq OWNER TO postgres;

--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 201
-- Name: area_profile_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE area_profile_gid_seq OWNED BY area_profile.gid;


--
-- TOC entry 202 (class 1259 OID 17752)
-- Name: ba_unit; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit (
    land_area double precision,
    owner character varying(100),
    who_manages character varying(25),
    disputes character varying(100),
    dispute_with character varying(100),
    common_floor_size character varying(25),
    common_structures character varying(25),
    gid integer NOT NULL,
    area_id integer,
    comments character varying(200),
    tenure_effort character varying(10)
);


ALTER TABLE public.ba_unit OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 17758)
-- Name: ba_unit_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ba_unit_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ba_unit_gid_seq OWNER TO postgres;

--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 203
-- Name: ba_unit_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ba_unit_gid_seq OWNED BY ba_unit.gid;


--
-- TOC entry 204 (class 1259 OID 17760)
-- Name: base_imagery; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE base_imagery (
    base_imagery_name character varying(50) NOT NULL,
    base_image_srs integer,
    gid integer NOT NULL,
    area_id integer NOT NULL
);


ALTER TABLE public.base_imagery OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 17763)
-- Name: base_imagery_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE base_imagery_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.base_imagery_gid_seq OWNER TO postgres;

--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 205
-- Name: base_imagery_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE base_imagery_gid_seq OWNED BY base_imagery.gid;


--
-- TOC entry 206 (class 1259 OID 17765)
-- Name: base_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE base_service (
    affordability integer,
    quality integer,
    accessibility integer,
    comments text,
    type integer,
    gid integer NOT NULL
);


ALTER TABLE public.base_service OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 17771)
-- Name: base_service_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE base_service_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.base_service_gid_seq OWNER TO postgres;

--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 207
-- Name: base_service_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE base_service_gid_seq OWNED BY base_service.gid;


--
-- TOC entry 208 (class 1259 OID 17773)
-- Name: business; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE business (
    gid integer NOT NULL,
    business_name character varying(35),
    owner character varying(25),
    operator character varying(25),
    age_of_business integer,
    license_status character varying(25),
    authority character varying(25),
    monthly_income character varying(25),
    type_of_business character varying(25),
    structure_id integer,
    age_of_structure integer
);


ALTER TABLE public.business OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 17776)
-- Name: business_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE business_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.business_gid_seq OWNER TO postgres;

--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 209
-- Name: business_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE business_gid_seq OWNED BY business.gid;


--
-- TOC entry 210 (class 1259 OID 17778)
-- Name: businesses; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW businesses AS
    SELECT spatial_unit.identity AS structure_number, business.business_name, business.age_of_business AS age, business.license_status, business.authority AS licensing_authority, business.type_of_business AS type, business.owner, business.operator FROM spatial_unit, business WHERE (spatial_unit.gid = business.structure_id);


ALTER TABLE public.businesses OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 17782)
-- Name: check_priority_project; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_priority_project (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_priority_project OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 17785)
-- Name: check_bath_facility_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_bath_facility_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_bath_facility_sequence_seq OWNER TO postgres;

--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 212
-- Name: check_bath_facility_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_bath_facility_sequence_seq OWNED BY check_priority_project.sequence;


--
-- TOC entry 213 (class 1259 OID 17787)
-- Name: check_cost_of_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_cost_of_service (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_cost_of_service OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 17790)
-- Name: check_daily_expenditure; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_daily_expenditure (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_daily_expenditure OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 17793)
-- Name: check_data_collector_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_data_collector_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_data_collector_type OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17796)
-- Name: check_structure_extension; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_structure_extension (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL,
    ext_id character varying(10)
);


ALTER TABLE public.check_structure_extension OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17799)
-- Name: check_disposal_dump_location_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_disposal_dump_location_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_disposal_dump_location_sequence_seq OWNER TO postgres;

--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 217
-- Name: check_disposal_dump_location_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_disposal_dump_location_sequence_seq OWNED BY check_structure_extension.sequence;


--
-- TOC entry 218 (class 1259 OID 17801)
-- Name: check_land_owner; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_land_owner (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_land_owner OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17804)
-- Name: check_distance_source_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_distance_source_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_distance_source_sequence_seq OWNER TO postgres;

--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 219
-- Name: check_distance_source_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_distance_source_sequence_seq OWNED BY check_land_owner.sequence;


--
-- TOC entry 220 (class 1259 OID 17806)
-- Name: check_distance_to_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_distance_to_service (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_distance_to_service OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17809)
-- Name: check_education_level; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_education_level (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_education_level OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17812)
-- Name: check_finance_option; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_finance_option (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_finance_option OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17815)
-- Name: check_finance_option_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_finance_option_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_finance_option_sequence_seq OWNER TO postgres;

--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 223
-- Name: check_finance_option_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_finance_option_sequence_seq OWNED BY check_finance_option.sequence;


--
-- TOC entry 224 (class 1259 OID 17817)
-- Name: check_gender; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_gender (
    sequence integer NOT NULL,
    value character varying(25) NOT NULL
);


ALTER TABLE public.check_gender OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17820)
-- Name: check_group_person_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_group_person_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL
);


ALTER TABLE public.check_group_person_type OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17823)
-- Name: check_house_shape; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_house_shape (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_house_shape OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17826)
-- Name: check_house_type_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_house_type_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_house_type_sequence_seq OWNER TO postgres;

--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 227
-- Name: check_house_type_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_house_type_sequence_seq OWNED BY check_house_shape.sequence;


--
-- TOC entry 228 (class 1259 OID 17828)
-- Name: check_household_relation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_household_relation (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_household_relation OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17831)
-- Name: check_household_tenure_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_household_tenure_status (
    sequence integer NOT NULL,
    value character varying(50)
);


ALTER TABLE public.check_household_tenure_status OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17834)
-- Name: check_location_of_settlement; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_location_of_settlement (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_location_of_settlement OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17837)
-- Name: check_management_of_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_management_of_service (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_management_of_service OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17840)
-- Name: check_marital_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_marital_status (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_marital_status OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17843)
-- Name: check_monthy_household_income; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_monthy_household_income (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_monthy_household_income OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17846)
-- Name: check_montly_rent; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_montly_rent (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_montly_rent OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17849)
-- Name: check_occupation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_occupation (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_occupation OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17852)
-- Name: check_owner_residence; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_owner_residence (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_owner_residence OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 17855)
-- Name: check_owner_residence_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_owner_residence_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_owner_residence_sequence_seq OWNER TO postgres;

--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 237
-- Name: check_owner_residence_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_owner_residence_sequence_seq OWNED BY check_owner_residence.sequence;


--
-- TOC entry 238 (class 1259 OID 17857)
-- Name: check_ownership_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_ownership_type (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_ownership_type OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 17860)
-- Name: check_ownership_type_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_ownership_type_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_ownership_type_sequence_seq OWNER TO postgres;

--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 239
-- Name: check_ownership_type_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_ownership_type_sequence_seq OWNED BY check_ownership_type.sequence;


--
-- TOC entry 240 (class 1259 OID 17862)
-- Name: check_pit_empty_mode_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_pit_empty_mode_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_pit_empty_mode_sequence_seq OWNER TO postgres;

--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 240
-- Name: check_pit_empty_mode_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_pit_empty_mode_sequence_seq OWNED BY check_montly_rent.sequence;


--
-- TOC entry 241 (class 1259 OID 17864)
-- Name: check_poverty_level; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_poverty_level (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_poverty_level OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17867)
-- Name: check_previous_residence; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_previous_residence (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_previous_residence OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17870)
-- Name: check_previous_residence_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_previous_residence_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_previous_residence_sequence_seq OWNER TO postgres;

--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 243
-- Name: check_previous_residence_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_previous_residence_sequence_seq OWNED BY check_previous_residence.sequence;


--
-- TOC entry 244 (class 1259 OID 17872)
-- Name: project_facility; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE project_facility (
    gid integer NOT NULL,
    project_area character varying(50) NOT NULL,
    other_facility character varying(25),
    facility_name character varying(25)
);


ALTER TABLE public.project_facility OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17875)
-- Name: check_project_facility_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_project_facility_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_project_facility_gid_seq OWNER TO postgres;

--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 245
-- Name: check_project_facility_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_project_facility_gid_seq OWNED BY project_facility.gid;


--
-- TOC entry 246 (class 1259 OID 17877)
-- Name: check_project_facility_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_project_facility_type (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_project_facility_type OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17880)
-- Name: check_quality_of_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_quality_of_service (
    sequence integer NOT NULL,
    value character varying(25)
);


ALTER TABLE public.check_quality_of_service OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17883)
-- Name: check_security_of_settlement; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_security_of_settlement (
    sequence integer,
    value character varying(25)
);


ALTER TABLE public.check_security_of_settlement OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17886)
-- Name: check_settlement_period; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_settlement_period (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_settlement_period OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 17889)
-- Name: check_settlement_reason; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_settlement_reason (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_settlement_reason OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 17892)
-- Name: check_settlement_reason_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_settlement_reason_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_settlement_reason_sequence_seq OWNER TO postgres;

--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 251
-- Name: check_settlement_reason_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_settlement_reason_sequence_seq OWNED BY check_settlement_reason.sequence;


--
-- TOC entry 252 (class 1259 OID 17894)
-- Name: check_social_tenure_inventory_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_social_tenure_inventory_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_social_tenure_inventory_type OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17897)
-- Name: check_social_tenure_relationship_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_social_tenure_relationship_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_social_tenure_relationship_type OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17900)
-- Name: check_spatial_unit_inventory_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_spatial_unit_inventory_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_spatial_unit_inventory_type OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17903)
-- Name: check_spatial_unit_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_spatial_unit_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15)
);


ALTER TABLE public.check_spatial_unit_type OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 17906)
-- Name: check_spatial_unit_use_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_spatial_unit_use_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL,
    icon character varying(15),
    category_id character varying(10)
);


ALTER TABLE public.check_spatial_unit_use_type OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17909)
-- Name: check_survey_point_quality_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_survey_point_quality_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL
);


ALTER TABLE public.check_survey_point_quality_type OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 17912)
-- Name: check_survey_point_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_survey_point_type (
    sequence integer NOT NULL,
    value character varying(50) NOT NULL
);


ALTER TABLE public.check_survey_point_type OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17915)
-- Name: check_tenure_relationship; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_tenure_relationship (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_tenure_relationship OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 17918)
-- Name: check_toilet_facility_type_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_toilet_facility_type_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_toilet_facility_type_sequence_seq OWNER TO postgres;

--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 260
-- Name: check_toilet_facility_type_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_toilet_facility_type_sequence_seq OWNED BY check_project_facility_type.sequence;


--
-- TOC entry 261 (class 1259 OID 17920)
-- Name: check_who_responding; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_who_responding (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_who_responding OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 17923)
-- Name: check_toilet_quality_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_toilet_quality_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_toilet_quality_sequence_seq OWNER TO postgres;

--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 262
-- Name: check_toilet_quality_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_toilet_quality_sequence_seq OWNED BY check_who_responding.sequence;


--
-- TOC entry 263 (class 1259 OID 17925)
-- Name: check_toilet_satisfaction_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_toilet_satisfaction_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_toilet_satisfaction_sequence_seq OWNER TO postgres;

--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 263
-- Name: check_toilet_satisfaction_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_toilet_satisfaction_sequence_seq OWNED BY check_settlement_period.sequence;


--
-- TOC entry 264 (class 1259 OID 17927)
-- Name: check_transport_cost; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_transport_cost (
    sequence integer NOT NULL,
    value character varying(25) NOT NULL
);


ALTER TABLE public.check_transport_cost OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 17930)
-- Name: check_type_of_house; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE check_type_of_house (
    sequence integer NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE public.check_type_of_house OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 17933)
-- Name: check_type_of_work_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_type_of_work_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_type_of_work_sequence_seq OWNER TO postgres;

--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 266
-- Name: check_type_of_work_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_type_of_work_sequence_seq OWNED BY check_type_of_house.sequence;


--
-- TOC entry 267 (class 1259 OID 17935)
-- Name: check_waste_type_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_waste_type_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_waste_type_sequence_seq OWNER TO postgres;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 267
-- Name: check_waste_type_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_waste_type_sequence_seq OWNED BY check_household_relation.sequence;


--
-- TOC entry 268 (class 1259 OID 17937)
-- Name: check_water_availability_duration_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_water_availability_duration_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_water_availability_duration_sequence_seq OWNER TO postgres;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 268
-- Name: check_water_availability_duration_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_water_availability_duration_sequence_seq OWNED BY check_tenure_relationship.sequence;


--
-- TOC entry 269 (class 1259 OID 17939)
-- Name: check_water_availability_week_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_water_availability_week_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_water_availability_week_sequence_seq OWNER TO postgres;

--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 269
-- Name: check_water_availability_week_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_water_availability_week_sequence_seq OWNED BY check_occupation.sequence;


--
-- TOC entry 270 (class 1259 OID 17941)
-- Name: check_water_source_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_water_source_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_water_source_sequence_seq OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 270
-- Name: check_water_source_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_water_source_sequence_seq OWNED BY check_marital_status.sequence;


--
-- TOC entry 271 (class 1259 OID 17943)
-- Name: check_work_place_sequence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE check_work_place_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.check_work_place_sequence_seq OWNER TO postgres;

--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 271
-- Name: check_work_place_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE check_work_place_sequence_seq OWNED BY check_education_level.sequence;


--
-- TOC entry 272 (class 1259 OID 17945)
-- Name: project_area; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE project_area (
    bounding_box box2d,
    area_id character varying(35) NOT NULL,
    code_name character varying(10),
    city character varying(50),
    country_gid integer,
    gid integer NOT NULL,
    location character varying(50),
    municipality character varying(25),
    landmark character varying(35),
    perimeter character varying(35),
    category character varying(25)
);


ALTER TABLE public.project_area OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 17948)
-- Name: respondent; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE respondent (
    gid integer NOT NULL,
    res_sur_name character varying(50),
    res_other_name character varying(50),
    res_relation character varying(50),
    gender character varying(25),
    contact character varying(25),
    has_witness character varying(10),
    external_relation character varying(25),
    house_number character varying(25),
    profile_type character varying(25),
    area_id integer
);


ALTER TABLE public.respondent OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 17951)
-- Name: contact_persons; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW contact_persons AS
    SELECT respondent.res_sur_name AS surname, respondent.res_other_name AS other_names, respondent.gender, respondent.contact, respondent.profile_type, project_area.area_id FROM respondent, project_area WHERE (respondent.area_id = project_area.gid);


ALTER TABLE public.contact_persons OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 17955)
-- Name: data_collector; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE data_collector (
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    data_collector_type character varying(50),
    contact character varying(100),
    gid integer NOT NULL,
    enumeration_date timestamp without time zone,
    verifier_surname character varying(50),
    verifier_othername character varying(50),
    verification_date timestamp without time zone,
    submission_date timestamp without time zone,
    date_entered timestamp without time zone,
    enumeration_end timestamp without time zone,
    gender character varying(20),
    settlement_id integer
);


ALTER TABLE public.data_collector OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17958)
-- Name: data_collector_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE data_collector_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.data_collector_gid_seq OWNER TO postgres;

--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 276
-- Name: data_collector_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE data_collector_gid_seq OWNED BY data_collector.gid;


--
-- TOC entry 277 (class 1259 OID 17960)
-- Name: demographic; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE demographic (
    gid integer NOT NULL,
    category_type character varying(25),
    category_name character varying(25),
    total_men integer,
    total_women integer,
    total_children integer,
    area_in character varying(25),
    settlement_id integer,
    female_child integer,
    male_child integer
);


ALTER TABLE public.demographic OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 18527)
-- Name: demographic_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW demographic_details AS
    SELECT demographic.category_name, demographic.category_type, demographic.total_men, demographic.total_women, demographic.male_child, demographic.female_child, area_profile.status_of_slum, area_profile.poverty_level, project_area.area_id AS settlement_name FROM demographic, area_profile, project_area WHERE ((demographic.settlement_id = project_area.gid) AND (area_profile.area_id = project_area.gid));


ALTER TABLE public.demographic_details OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 17967)
-- Name: demographic_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE demographic_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.demographic_gid_seq OWNER TO postgres;

--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 278
-- Name: demographic_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE demographic_gid_seq OWNED BY demographic.gid;


--
-- TOC entry 279 (class 1259 OID 17969)
-- Name: group_party; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party (
    non_natural_person_gid integer NOT NULL,
    party_gid integer NOT NULL
);


ALTER TABLE public.group_party OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 17972)
-- Name: group_person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE group_person (
    gid integer NOT NULL,
    group_name character varying(25),
    sp_unit_id integer,
    rep_person_gid integer,
    group_logo bytea,
    ownership_type character varying(25),
    owner_name character varying(50),
    other_names character varying(50),
    land_owner character varying(50),
    land_owner_othername character varying(50),
    institution_name character varying(50)
);


ALTER TABLE public.group_person OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 17978)
-- Name: group_person_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE group_person_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_person_gid_seq OWNER TO postgres;

--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 281
-- Name: group_person_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE group_person_gid_seq OWNED BY group_person.gid;


--
-- TOC entry 282 (class 1259 OID 17980)
-- Name: household; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE household (
    household_no character varying(100) NOT NULL,
    male_over18 integer,
    fem_over18 integer,
    male_under18 integer,
    fem_under18 integer,
    stay_period character varying(100),
    previous_res character varying(100),
    settlement_reason character varying(100),
    tenure_status character varying(100),
    share numeric,
    monthly_rent character varying(100),
    finance_saving character varying(100),
    disability character varying(100),
    gid integer NOT NULL,
    total_person integer,
    contract_evidence character varying(25),
    no_of_diasability integer DEFAULT 0,
    daily_expense character varying(50),
    income_per_month character varying(50),
    commuting_expense character varying(50),
    house_gid integer
);


ALTER TABLE public.household OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 17987)
-- Name: household_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE household_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.household_gid_seq OWNER TO postgres;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 283
-- Name: household_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE household_gid_seq OWNED BY household.gid;


--
-- TOC entry 284 (class 1259 OID 17989)
-- Name: household_report; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW household_report AS
    SELECT household.household_no, household.stay_period, household.previous_res, household.settlement_reason FROM household;


ALTER TABLE public.household_report OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 17993)
-- Name: households; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW households AS
    SELECT household.household_no AS house_number, household.tenure_status AS tenure, household.male_over18 AS adult_male, household.fem_over18 AS adult_female, household.fem_under18 AS girls, household.male_under18 AS boys, household.stay_period, household.finance_saving AS savings, household.monthly_rent AS rent, household.total_person AS family_members, household.settlement_reason, household.previous_res AS previous_residence, household.daily_expense, spatial_unit.project_name AS settlement, admin_spatial_unit_set.name AS zone FROM household, spatial_unit, admin_spatial_unit_set WHERE ((household.house_gid = spatial_unit.gid) AND (spatial_unit.admin_spatial_unit_set_gid = admin_spatial_unit_set.gid));


ALTER TABLE public.households OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 17998)
-- Name: natural_person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE natural_person (
    first_name character varying(100),
    last_name character varying(100),
    gender character varying(25),
    photo bytea,
    mobile character varying(100),
    gid integer NOT NULL,
    identity character varying(50),
    age integer DEFAULT 0,
    occupation character varying(100),
    education character varying(100),
    occ_age_below integer DEFAULT 0,
    tenure_relation character varying(50),
    household_relation character varying(50),
    witness character varying(10),
    household_no character varying(50),
    marital_status character varying(50),
    who_responded character varying(50),
    person_share integer DEFAULT 0,
    household_gid integer,
    CONSTRAINT check_gender CHECK (((gender)::text = ANY (ARRAY[('Male'::character varying)::text, ('Female'::character varying)::text])))
);


ALTER TABLE public.natural_person OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 18008)
-- Name: natural_person_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE natural_person_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.natural_person_gid_seq OWNER TO postgres;

--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 287
-- Name: natural_person_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE natural_person_gid_seq OWNED BY natural_person.gid;


--
-- TOC entry 320 (class 1259 OID 18501)
-- Name: party; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW party AS
    SELECT natural_person.first_name AS surname, natural_person.last_name AS other_names, natural_person.gender, natural_person.age, natural_person.identity, natural_person.occupation, natural_person.education, natural_person.tenure_relation AS tenure, natural_person.household_relation, household.household_no AS house, natural_person.marital_status, natural_person.mobile AS contact, spatial_unit.project_name AS settlement, admin_spatial_unit_set.name AS zone FROM natural_person, spatial_unit, admin_spatial_unit_set, household WHERE ((((natural_person.household_no)::text = (spatial_unit.identity)::text) AND (spatial_unit.admin_spatial_unit_set_gid = admin_spatial_unit_set.gid)) AND (household.gid = natural_person.household_gid));


ALTER TABLE public.party OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 18015)
-- Name: persons_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW persons_view AS
    SELECT natural_person.first_name, natural_person.last_name FROM natural_person;


ALTER TABLE public.persons_view OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 18019)
-- Name: profilers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW profilers AS
    SELECT data_collector.first_name, data_collector.last_name, data_collector.data_collector_type AS profile_type, data_collector.contact, data_collector.gender, project_area.area_id AS settlement FROM data_collector, project_area WHERE (data_collector.settlement_id = project_area.gid);


ALTER TABLE public.profilers OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 18023)
-- Name: project_area_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE project_area_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_area_gid_seq OWNER TO postgres;

--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 290
-- Name: project_area_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE project_area_gid_seq OWNED BY project_area.gid;


--
-- TOC entry 291 (class 1259 OID 18025)
-- Name: project_region; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE project_region (
    gid integer NOT NULL,
    country_name character varying(30),
    state_name character varying(30),
    province character varying(25),
    district_name character varying(25),
    municipality character varying(25),
    region character varying(25)
);


ALTER TABLE public.project_region OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 18028)
-- Name: project_region_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE project_region_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_region_gid_seq OWNER TO postgres;

--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 292
-- Name: project_region_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE project_region_gid_seq OWNED BY project_region.gid;


--
-- TOC entry 293 (class 1259 OID 18030)
-- Name: respondent_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE respondent_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.respondent_gid_seq OWNER TO postgres;

--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 293
-- Name: respondent_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE respondent_gid_seq OWNED BY respondent.gid;


--
-- TOC entry 294 (class 1259 OID 18032)
-- Name: respondent_priority; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE respondent_priority (
    gid integer NOT NULL,
    priority character varying(50),
    priority_b character varying(50),
    priority_c character varying(50),
    priority_d character varying(50),
    priority_e character varying(50),
    res_gid integer,
    area_id integer
);


ALTER TABLE public.respondent_priority OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 18035)
-- Name: respondent_priority_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE respondent_priority_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.respondent_priority_gid_seq OWNER TO postgres;

--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 295
-- Name: respondent_priority_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE respondent_priority_gid_seq OWNED BY respondent_priority.gid;


--
-- TOC entry 296 (class 1259 OID 18037)
-- Name: services; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE services (
    gid integer NOT NULL,
    service_name character varying(50),
    service_source character varying(50),
    service_status character varying(50),
    service_operator character varying(50),
    proximity character varying(50),
    average_distance numeric,
    service_quality character varying(50),
    service_cost character varying(50),
    average_cost numeric,
    other_comments character varying(250),
    settlement integer NOT NULL
);


ALTER TABLE public.services OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 18043)
-- Name: services_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE services_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.services_gid_seq OWNER TO postgres;

--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 297
-- Name: services_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE services_gid_seq OWNED BY services.gid;


--
-- TOC entry 298 (class 1259 OID 18045)
-- Name: services_settlement_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE services_settlement_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.services_settlement_seq OWNER TO postgres;

--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 298
-- Name: services_settlement_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE services_settlement_seq OWNED BY services.settlement;


--
-- TOC entry 299 (class 1259 OID 18047)
-- Name: settlement_priorities; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW settlement_priorities AS
    SELECT respondent_priority.priority, respondent_priority.priority_b, respondent_priority.priority_c, respondent_priority.priority_d, respondent_priority.priority_e, project_area.area_id FROM respondent_priority, project_area WHERE (project_area.gid = respondent_priority.area_id);


ALTER TABLE public.settlement_priorities OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 18051)
-- Name: settlement_profile; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW settlement_profile AS
    SELECT area_profile.total_population, area_profile.total_household, area_profile.year_established, area_profile.status_of_slum, area_profile.poverty_level, area_profile.history, area_profile.comments, project_area.area_id AS settlement_name, project_area.location, project_area.perimeter, project_area.municipality FROM area_profile, project_area WHERE (area_profile.area_id = project_area.gid);


ALTER TABLE public.settlement_profile OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 18055)
-- Name: settlement_structures; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW settlement_structures AS
    SELECT spatial_unit.project_name AS settlement, spatial_unit.identity AS structure_number, spatial_unit.use_type AS use, spatial_unit.structure_length, spatial_unit.structure_width, spatial_unit.perimeter, spatial_unit.house_type, admin_spatial_unit_set.name AS cluster FROM spatial_unit, admin_spatial_unit_set WHERE (spatial_unit.admin_spatial_unit_set_gid = admin_spatial_unit_set.gid);


ALTER TABLE public.settlement_structures OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 18059)
-- Name: social_tenure_relationship; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE social_tenure_relationship (
    social_tenure_relationship_type character varying(50) NOT NULL,
    spatial_unit_gid integer,
    share numeric,
    gid integer NOT NULL,
    natural_person_gid integer,
    non_natural_person_gid integer,
    ownership_type character varying(30),
    CONSTRAINT check_share_100 CHECK ((share <= (100)::numeric))
);


ALTER TABLE public.social_tenure_relationship OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 18066)
-- Name: social_tenure_relationship_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE social_tenure_relationship_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.social_tenure_relationship_gid_seq OWNER TO postgres;

--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 303
-- Name: social_tenure_relationship_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE social_tenure_relationship_gid_seq OWNED BY social_tenure_relationship.gid;


--
-- TOC entry 304 (class 1259 OID 18068)
-- Name: source_document; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE source_document (
    id character varying(50) NOT NULL,
    recordation date NOT NULL,
    scanned_source_document character varying(500),
    location_scanned_source_document character varying(1000),
    quality_type character varying(50),
    social_tenure_inventory_type character varying(50),
    spatial_unit_inventory_type character varying(50),
    comments character varying(2000),
    srs_id integer DEFAULT 0,
    gid integer NOT NULL,
    source_doc_admin_unit_id integer,
    person_gid integer,
    struct_gid integer,
    entity_name character varying(50),
    househld_gid integer
);


ALTER TABLE public.source_document OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 18075)
-- Name: source_document_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE source_document_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.source_document_gid_seq OWNER TO postgres;

--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 305
-- Name: source_document_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE source_document_gid_seq OWNED BY source_document.gid;


--
-- TOC entry 306 (class 1259 OID 18077)
-- Name: spatial_unit_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE spatial_unit_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spatial_unit_gid_seq OWNER TO postgres;

--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 306
-- Name: spatial_unit_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE spatial_unit_gid_seq OWNED BY spatial_unit.gid;


--
-- TOC entry 307 (class 1259 OID 18079)
-- Name: stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW stats AS
    SELECT DISTINCT spatial_unit.use_type, count(*) AS count FROM spatial_unit GROUP BY spatial_unit.use_type ORDER BY count(*) DESC LIMIT 8;


ALTER TABLE public.stats OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 18083)
-- Name: stdmusers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stdmusers (
    stdm_username character varying NOT NULL,
    stdm_role integer
);


ALTER TABLE public.stdmusers OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 18089)
-- Name: structures; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE structures (
    settlement_id integer,
    structure_type character varying(50),
    total integer,
    gid integer NOT NULL
);


ALTER TABLE public.structures OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 18092)
-- Name: structure; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW structure AS
    SELECT structures.structure_type, structures.total FROM structures;


ALTER TABLE public.structure OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 18096)
-- Name: structure_count; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW structure_count AS
    SELECT structures.structure_type, structures.total, project_area.area_id AS settlement FROM structures, project_area WHERE (structures.settlement_id = project_area.gid);


ALTER TABLE public.structure_count OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 18100)
-- Name: structure_facility; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE structure_facility (
    gid integer NOT NULL,
    water character varying(10),
    toilet character varying(10),
    electricity character varying(10),
    extension_id character varying(25),
    extension_name character varying,
    structure_id integer,
    extension_2 character varying(50),
    extension_3 character varying(50),
    extension_4 character varying(50)
);


ALTER TABLE public.structure_facility OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 18106)
-- Name: structure_facility_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE structure_facility_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.structure_facility_gid_seq OWNER TO postgres;

--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 313
-- Name: structure_facility_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE structure_facility_gid_seq OWNED BY structure_facility.gid;


--
-- TOC entry 314 (class 1259 OID 18108)
-- Name: structures_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE structures_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.structures_gid_seq OWNER TO postgres;

--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 314
-- Name: structures_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE structures_gid_seq OWNED BY structures.gid;


--
-- TOC entry 315 (class 1259 OID 18110)
-- Name: supporting_source_document; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supporting_source_document (
    source_document_gid integer NOT NULL,
    social_tenure_relationship integer NOT NULL
);


ALTER TABLE public.supporting_source_document OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 18113)
-- Name: tableroles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tableroles (
    tablename character varying,
    rolelist character varying
);


ALTER TABLE public.tableroles OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 18119)
-- Name: water_service; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE water_service (
    source integer
)
INHERITS (base_service);


ALTER TABLE public.water_service OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 18125)
-- Name: witness; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE witness (
    gid integer NOT NULL,
    sur_name character varying(100) NOT NULL,
    other_names character varying(100) NOT NULL,
    "position" character varying(50),
    respondent_gid integer,
    contact integer
);


ALTER TABLE public.witness OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 18128)
-- Name: witness_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE witness_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.witness_gid_seq OWNER TO postgres;

--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 319
-- Name: witness_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE witness_gid_seq OWNED BY witness.gid;


--
-- TOC entry 3597 (class 2604 OID 18130)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY admin_spatial_unit_set ALTER COLUMN gid SET DEFAULT nextval('admin_spatial_unit_set_gid_seq'::regclass);


--
-- TOC entry 3598 (class 2604 OID 18131)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY area_profile ALTER COLUMN gid SET DEFAULT nextval('area_profile_gid_seq'::regclass);


--
-- TOC entry 3599 (class 2604 OID 18132)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ba_unit ALTER COLUMN gid SET DEFAULT nextval('ba_unit_gid_seq'::regclass);


--
-- TOC entry 3600 (class 2604 OID 18133)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY base_imagery ALTER COLUMN gid SET DEFAULT nextval('base_imagery_gid_seq'::regclass);


--
-- TOC entry 3601 (class 2604 OID 18134)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY base_service ALTER COLUMN gid SET DEFAULT nextval('base_service_gid_seq'::regclass);


--
-- TOC entry 3602 (class 2604 OID 18137)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY business ALTER COLUMN gid SET DEFAULT nextval('business_gid_seq'::regclass);


--
-- TOC entry 3606 (class 2604 OID 18138)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_education_level ALTER COLUMN sequence SET DEFAULT nextval('check_work_place_sequence_seq'::regclass);


--
-- TOC entry 3607 (class 2604 OID 18139)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_finance_option ALTER COLUMN sequence SET DEFAULT nextval('check_finance_option_sequence_seq'::regclass);


--
-- TOC entry 3608 (class 2604 OID 18140)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_house_shape ALTER COLUMN sequence SET DEFAULT nextval('check_house_type_sequence_seq'::regclass);


--
-- TOC entry 3609 (class 2604 OID 18141)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_household_relation ALTER COLUMN sequence SET DEFAULT nextval('check_waste_type_sequence_seq'::regclass);


--
-- TOC entry 3605 (class 2604 OID 18142)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_land_owner ALTER COLUMN sequence SET DEFAULT nextval('check_distance_source_sequence_seq'::regclass);


--
-- TOC entry 3610 (class 2604 OID 18143)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_marital_status ALTER COLUMN sequence SET DEFAULT nextval('check_water_source_sequence_seq'::regclass);


--
-- TOC entry 3611 (class 2604 OID 18144)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_montly_rent ALTER COLUMN sequence SET DEFAULT nextval('check_pit_empty_mode_sequence_seq'::regclass);


--
-- TOC entry 3612 (class 2604 OID 18145)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_occupation ALTER COLUMN sequence SET DEFAULT nextval('check_water_availability_week_sequence_seq'::regclass);


--
-- TOC entry 3613 (class 2604 OID 18146)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_owner_residence ALTER COLUMN sequence SET DEFAULT nextval('check_owner_residence_sequence_seq'::regclass);


--
-- TOC entry 3614 (class 2604 OID 18147)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_ownership_type ALTER COLUMN sequence SET DEFAULT nextval('check_ownership_type_sequence_seq'::regclass);


--
-- TOC entry 3615 (class 2604 OID 18148)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_previous_residence ALTER COLUMN sequence SET DEFAULT nextval('check_previous_residence_sequence_seq'::regclass);


--
-- TOC entry 3603 (class 2604 OID 18149)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_priority_project ALTER COLUMN sequence SET DEFAULT nextval('check_bath_facility_sequence_seq'::regclass);


--
-- TOC entry 3617 (class 2604 OID 18150)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_project_facility_type ALTER COLUMN sequence SET DEFAULT nextval('check_toilet_facility_type_sequence_seq'::regclass);


--
-- TOC entry 3618 (class 2604 OID 18151)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_settlement_period ALTER COLUMN sequence SET DEFAULT nextval('check_toilet_satisfaction_sequence_seq'::regclass);


--
-- TOC entry 3619 (class 2604 OID 18152)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_settlement_reason ALTER COLUMN sequence SET DEFAULT nextval('check_settlement_reason_sequence_seq'::regclass);


--
-- TOC entry 3604 (class 2604 OID 18153)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_structure_extension ALTER COLUMN sequence SET DEFAULT nextval('check_disposal_dump_location_sequence_seq'::regclass);


--
-- TOC entry 3620 (class 2604 OID 18154)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_tenure_relationship ALTER COLUMN sequence SET DEFAULT nextval('check_water_availability_duration_sequence_seq'::regclass);


--
-- TOC entry 3622 (class 2604 OID 18155)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_type_of_house ALTER COLUMN sequence SET DEFAULT nextval('check_type_of_work_sequence_seq'::regclass);


--
-- TOC entry 3621 (class 2604 OID 18156)
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY check_who_responding ALTER COLUMN sequence SET DEFAULT nextval('check_toilet_quality_sequence_seq'::regclass);


--
-- TOC entry 3625 (class 2604 OID 18157)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY data_collector ALTER COLUMN gid SET DEFAULT nextval('data_collector_gid_seq'::regclass);


--
-- TOC entry 3626 (class 2604 OID 18158)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY demographic ALTER COLUMN gid SET DEFAULT nextval('demographic_gid_seq'::regclass);


--
-- TOC entry 3627 (class 2604 OID 18159)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY group_person ALTER COLUMN gid SET DEFAULT nextval('group_person_gid_seq'::regclass);


--
-- TOC entry 3629 (class 2604 OID 18160)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY household ALTER COLUMN gid SET DEFAULT nextval('household_gid_seq'::regclass);


--
-- TOC entry 3633 (class 2604 OID 18161)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY natural_person ALTER COLUMN gid SET DEFAULT nextval('natural_person_gid_seq'::regclass);


--
-- TOC entry 3623 (class 2604 OID 18163)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_area ALTER COLUMN gid SET DEFAULT nextval('project_area_gid_seq'::regclass);


--
-- TOC entry 3616 (class 2604 OID 18164)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_facility ALTER COLUMN gid SET DEFAULT nextval('check_project_facility_gid_seq'::regclass);


--
-- TOC entry 3635 (class 2604 OID 18165)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_region ALTER COLUMN gid SET DEFAULT nextval('project_region_gid_seq'::regclass);


--
-- TOC entry 3624 (class 2604 OID 18166)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY respondent ALTER COLUMN gid SET DEFAULT nextval('respondent_gid_seq'::regclass);


--
-- TOC entry 3636 (class 2604 OID 18167)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY respondent_priority ALTER COLUMN gid SET DEFAULT nextval('respondent_priority_gid_seq'::regclass);


--
-- TOC entry 3637 (class 2604 OID 18168)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY services ALTER COLUMN gid SET DEFAULT nextval('services_gid_seq'::regclass);


--
-- TOC entry 3638 (class 2604 OID 18169)
-- Name: settlement; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY services ALTER COLUMN settlement SET DEFAULT nextval('services_settlement_seq'::regclass);


--
-- TOC entry 3639 (class 2604 OID 18170)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY social_tenure_relationship ALTER COLUMN gid SET DEFAULT nextval('social_tenure_relationship_gid_seq'::regclass);


--
-- TOC entry 3642 (class 2604 OID 18171)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY source_document ALTER COLUMN gid SET DEFAULT nextval('source_document_gid_seq'::regclass);


--
-- TOC entry 3585 (class 2604 OID 18172)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY spatial_unit ALTER COLUMN gid SET DEFAULT nextval('spatial_unit_gid_seq'::regclass);


--
-- TOC entry 3644 (class 2604 OID 18173)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY structure_facility ALTER COLUMN gid SET DEFAULT nextval('structure_facility_gid_seq'::regclass);


--
-- TOC entry 3643 (class 2604 OID 18174)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY structures ALTER COLUMN gid SET DEFAULT nextval('structures_gid_seq'::regclass);


--
-- TOC entry 3645 (class 2604 OID 18135)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY water_service ALTER COLUMN gid SET DEFAULT nextval('base_service_gid_seq'::regclass);


--
-- TOC entry 3646 (class 2604 OID 18175)
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY witness ALTER COLUMN gid SET DEFAULT nextval('witness_gid_seq'::regclass);


--
-- TOC entry 3656 (class 2606 OID 18186)
-- Name: area_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY area_profile
    ADD CONSTRAINT area_profile_pkey PRIMARY KEY (gid, year_established, status_of_slum);


--
-- TOC entry 3658 (class 2606 OID 18188)
-- Name: ba_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_pkey PRIMARY KEY (gid);


--
-- TOC entry 3660 (class 2606 OID 18190)
-- Name: base_imagery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY base_imagery
    ADD CONSTRAINT base_imagery_pkey PRIMARY KEY (gid);


--
-- TOC entry 3662 (class 2606 OID 18192)
-- Name: base_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY base_service
    ADD CONSTRAINT base_service_pkey PRIMARY KEY (gid);


--
-- TOC entry 3664 (class 2606 OID 18194)
-- Name: business_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY business
    ADD CONSTRAINT business_pkey PRIMARY KEY (gid);


--
-- TOC entry 3668 (class 2606 OID 18196)
-- Name: check_cost_of_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_cost_of_service
    ADD CONSTRAINT check_cost_of_service_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3672 (class 2606 OID 18198)
-- Name: check_data_collector_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_data_collector_type
    ADD CONSTRAINT check_data_collector_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3678 (class 2606 OID 18200)
-- Name: check_distance_to_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_distance_to_service
    ADD CONSTRAINT check_distance_to_service_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3688 (class 2606 OID 18202)
-- Name: check_group_person_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_group_person_type
    ADD CONSTRAINT check_group_person_type_pk PRIMARY KEY (sequence);


--
-- TOC entry 3694 (class 2606 OID 18204)
-- Name: check_household_tenure_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_household_tenure_status
    ADD CONSTRAINT check_household_tenure_status_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3670 (class 2606 OID 18206)
-- Name: check_layer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_daily_expenditure
    ADD CONSTRAINT check_layer_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3696 (class 2606 OID 18208)
-- Name: check_location_of_settlement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_location_of_settlement
    ADD CONSTRAINT check_location_of_settlement_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3698 (class 2606 OID 18210)
-- Name: check_management_of_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_management_of_service
    ADD CONSTRAINT check_management_of_service_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3718 (class 2606 OID 18212)
-- Name: check_project_facility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY project_facility
    ADD CONSTRAINT check_project_facility_pkey PRIMARY KEY (gid);


--
-- TOC entry 3720 (class 2606 OID 18214)
-- Name: check_project_facility_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_project_facility_type
    ADD CONSTRAINT check_project_facility_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3722 (class 2606 OID 18216)
-- Name: check_quality_of_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_quality_of_service
    ADD CONSTRAINT check_quality_of_service_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3728 (class 2606 OID 18218)
-- Name: check_social_tenure_inventory_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_social_tenure_inventory_type
    ADD CONSTRAINT check_social_tenure_inventory_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3734 (class 2606 OID 18220)
-- Name: check_social_tenure_relationship_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_social_tenure_relationship_type
    ADD CONSTRAINT check_social_tenure_relationship_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3702 (class 2606 OID 18222)
-- Name: check_source_document_quality_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_monthy_household_income
    ADD CONSTRAINT check_source_document_quality_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3736 (class 2606 OID 18224)
-- Name: check_spatial_unit_inventory_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_spatial_unit_inventory_type
    ADD CONSTRAINT check_spatial_unit_inventory_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3742 (class 2606 OID 18226)
-- Name: check_spatial_unit_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_spatial_unit_type
    ADD CONSTRAINT check_spatial_unit_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3744 (class 2606 OID 18228)
-- Name: check_spatial_unit_use_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_spatial_unit_use_type
    ADD CONSTRAINT check_spatial_unit_use_type_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3758 (class 2606 OID 18230)
-- Name: check_transport_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_transport_cost
    ADD CONSTRAINT check_transport_cost_pkey PRIMARY KEY (sequence);


--
-- TOC entry 3768 (class 2606 OID 18232)
-- Name: data_collector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY data_collector
    ADD CONSTRAINT data_collector_pkey PRIMARY KEY (gid);


--
-- TOC entry 3770 (class 2606 OID 18526)
-- Name: demographic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY demographic
    ADD CONSTRAINT demographic_pkey PRIMARY KEY (gid);


--
-- TOC entry 3774 (class 2606 OID 18234)
-- Name: gid; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_person
    ADD CONSTRAINT gid PRIMARY KEY (gid);


--
-- TOC entry 3772 (class 2606 OID 18236)
-- Name: group_party_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_pkey PRIMARY KEY (non_natural_person_gid, party_gid);


--
-- TOC entry 3776 (class 2606 OID 18238)
-- Name: household_household_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY household
    ADD CONSTRAINT household_household_no_key UNIQUE (household_no);


--
-- TOC entry 3778 (class 2606 OID 18240)
-- Name: household_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY household
    ADD CONSTRAINT household_pkey PRIMARY KEY (gid);


--
-- TOC entry 3780 (class 2606 OID 18242)
-- Name: natural_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY natural_person
    ADD CONSTRAINT natural_person_pkey PRIMARY KEY (gid);


--
-- TOC entry 3654 (class 2606 OID 18244)
-- Name: pk_admin_spatial_unit_set; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY admin_spatial_unit_set
    ADD CONSTRAINT pk_admin_spatial_unit_set PRIMARY KEY (gid);


--
-- TOC entry 3666 (class 2606 OID 18246)
-- Name: pk_check_bath_facility; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_priority_project
    ADD CONSTRAINT pk_check_bath_facility PRIMARY KEY (sequence);


--
-- TOC entry 3674 (class 2606 OID 18248)
-- Name: pk_check_disposal_dump_location; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_structure_extension
    ADD CONSTRAINT pk_check_disposal_dump_location PRIMARY KEY (sequence);


--
-- TOC entry 3676 (class 2606 OID 18250)
-- Name: pk_check_distance_source; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_land_owner
    ADD CONSTRAINT pk_check_distance_source PRIMARY KEY (sequence);


--
-- TOC entry 3682 (class 2606 OID 18252)
-- Name: pk_check_finance_option; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_finance_option
    ADD CONSTRAINT pk_check_finance_option PRIMARY KEY (sequence);


--
-- TOC entry 3690 (class 2606 OID 18254)
-- Name: pk_check_house_type; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_house_shape
    ADD CONSTRAINT pk_check_house_type PRIMARY KEY (sequence);


--
-- TOC entry 3714 (class 2606 OID 18256)
-- Name: pk_check_ownership_type; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_ownership_type
    ADD CONSTRAINT pk_check_ownership_type PRIMARY KEY (sequence);


--
-- TOC entry 3708 (class 2606 OID 18258)
-- Name: pk_check_pit_empty_mode; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_montly_rent
    ADD CONSTRAINT pk_check_pit_empty_mode PRIMARY KEY (sequence);


--
-- TOC entry 3716 (class 2606 OID 18260)
-- Name: pk_check_previous_residence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_previous_residence
    ADD CONSTRAINT pk_check_previous_residence PRIMARY KEY (sequence);


--
-- TOC entry 3726 (class 2606 OID 18262)
-- Name: pk_check_settlement_reason; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_settlement_reason
    ADD CONSTRAINT pk_check_settlement_reason PRIMARY KEY (sequence);


--
-- TOC entry 3756 (class 2606 OID 18264)
-- Name: pk_check_toilet_quality; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_who_responding
    ADD CONSTRAINT pk_check_toilet_quality PRIMARY KEY (sequence);


--
-- TOC entry 3724 (class 2606 OID 18266)
-- Name: pk_check_toilet_satisfaction; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_settlement_period
    ADD CONSTRAINT pk_check_toilet_satisfaction PRIMARY KEY (sequence);


--
-- TOC entry 3692 (class 2606 OID 18268)
-- Name: pk_check_waste_type; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_household_relation
    ADD CONSTRAINT pk_check_waste_type PRIMARY KEY (sequence);


--
-- TOC entry 3754 (class 2606 OID 18270)
-- Name: pk_check_water_availability_duration; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_tenure_relationship
    ADD CONSTRAINT pk_check_water_availability_duration PRIMARY KEY (sequence);


--
-- TOC entry 3710 (class 2606 OID 18272)
-- Name: pk_check_water_availability_week; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_occupation
    ADD CONSTRAINT pk_check_water_availability_week PRIMARY KEY (sequence);


--
-- TOC entry 3700 (class 2606 OID 18274)
-- Name: pk_check_water_source; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_marital_status
    ADD CONSTRAINT pk_check_water_source PRIMARY KEY (sequence);


--
-- TOC entry 3680 (class 2606 OID 18276)
-- Name: pk_check_work_place; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_education_level
    ADD CONSTRAINT pk_check_work_place PRIMARY KEY (sequence);


--
-- TOC entry 3712 (class 2606 OID 18278)
-- Name: pk_owner_residence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_owner_residence
    ADD CONSTRAINT pk_owner_residence PRIMARY KEY (sequence);


--
-- TOC entry 3788 (class 2606 OID 18280)
-- Name: pk_social_tenure_relationship; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY social_tenure_relationship
    ADD CONSTRAINT pk_social_tenure_relationship PRIMARY KEY (gid);


--
-- TOC entry 3790 (class 2606 OID 18282)
-- Name: pk_source_document; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_document
    ADD CONSTRAINT pk_source_document PRIMARY KEY (gid);


--
-- TOC entry 3650 (class 2606 OID 18284)
-- Name: pk_spatial_unit; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT pk_spatial_unit PRIMARY KEY (gid);


--
-- TOC entry 3800 (class 2606 OID 18286)
-- Name: pk_supporting_source_document; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supporting_source_document
    ADD CONSTRAINT pk_supporting_source_document PRIMARY KEY (source_document_gid, social_tenure_relationship);


--
-- TOC entry 3760 (class 2606 OID 18288)
-- Name: pk_type_of_work; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_type_of_house
    ADD CONSTRAINT pk_type_of_work PRIMARY KEY (sequence);


--
-- TOC entry 3762 (class 2606 OID 18290)
-- Name: project_area_gid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY project_area
    ADD CONSTRAINT project_area_gid_key UNIQUE (gid);


--
-- TOC entry 3764 (class 2606 OID 18292)
-- Name: project_area_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY project_area
    ADD CONSTRAINT project_area_pk PRIMARY KEY (area_id);


--
-- TOC entry 3782 (class 2606 OID 18294)
-- Name: project_region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY project_region
    ADD CONSTRAINT project_region_pkey PRIMARY KEY (gid);


--
-- TOC entry 3766 (class 2606 OID 18296)
-- Name: respondent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY respondent
    ADD CONSTRAINT respondent_pkey PRIMARY KEY (gid);


--
-- TOC entry 3784 (class 2606 OID 18298)
-- Name: respondent_priority_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY respondent_priority
    ADD CONSTRAINT respondent_priority_pkey PRIMARY KEY (gid);


--
-- TOC entry 3786 (class 2606 OID 18300)
-- Name: services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (gid);


--
-- TOC entry 3652 (class 2606 OID 18302)
-- Name: spatial_unit_identity_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_identity_key UNIQUE (identity);


--
-- TOC entry 3794 (class 2606 OID 18304)
-- Name: stdmusers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stdmusers
    ADD CONSTRAINT stdmusers_pkey PRIMARY KEY (stdm_username);


--
-- TOC entry 3798 (class 2606 OID 18306)
-- Name: structure_facility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structure_facility
    ADD CONSTRAINT structure_facility_pkey PRIMARY KEY (gid);


--
-- TOC entry 3796 (class 2606 OID 18308)
-- Name: structures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structures
    ADD CONSTRAINT structures_pkey PRIMARY KEY (gid);


--
-- TOC entry 3684 (class 2606 OID 18310)
-- Name: uk_cgt_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_gender
    ADD CONSTRAINT uk_cgt_sequence UNIQUE (sequence);


--
-- TOC entry 3686 (class 2606 OID 18312)
-- Name: uk_cgt_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_gender
    ADD CONSTRAINT uk_cgt_value UNIQUE (value);


--
-- TOC entry 3704 (class 2606 OID 18314)
-- Name: uk_csdqt_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_monthy_household_income
    ADD CONSTRAINT uk_csdqt_sequence UNIQUE (sequence);


--
-- TOC entry 3706 (class 2606 OID 18316)
-- Name: uk_csdqt_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_monthy_household_income
    ADD CONSTRAINT uk_csdqt_value UNIQUE (value);


--
-- TOC entry 3746 (class 2606 OID 18318)
-- Name: uk_cspqt_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_survey_point_quality_type
    ADD CONSTRAINT uk_cspqt_sequence UNIQUE (sequence);


--
-- TOC entry 3748 (class 2606 OID 18320)
-- Name: uk_cspqt_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_survey_point_quality_type
    ADD CONSTRAINT uk_cspqt_value UNIQUE (value);


--
-- TOC entry 3750 (class 2606 OID 18322)
-- Name: uk_cspt_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_survey_point_type
    ADD CONSTRAINT uk_cspt_sequence UNIQUE (sequence);


--
-- TOC entry 3752 (class 2606 OID 18324)
-- Name: uk_cspt_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_survey_point_type
    ADD CONSTRAINT uk_cspt_value UNIQUE (value);


--
-- TOC entry 3730 (class 2606 OID 18326)
-- Name: uk_cstit_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_social_tenure_inventory_type
    ADD CONSTRAINT uk_cstit_sequence UNIQUE (sequence);


--
-- TOC entry 3732 (class 2606 OID 18328)
-- Name: uk_cstit_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_social_tenure_inventory_type
    ADD CONSTRAINT uk_cstit_value UNIQUE (value);


--
-- TOC entry 3738 (class 2606 OID 18330)
-- Name: uk_csuit_sequence; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_spatial_unit_inventory_type
    ADD CONSTRAINT uk_csuit_sequence UNIQUE (sequence);


--
-- TOC entry 3740 (class 2606 OID 18332)
-- Name: uk_csuit_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY check_spatial_unit_inventory_type
    ADD CONSTRAINT uk_csuit_value UNIQUE (value);


--
-- TOC entry 3792 (class 2606 OID 18334)
-- Name: uk_source_document_id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_document
    ADD CONSTRAINT uk_source_document_id UNIQUE (id);


--
-- TOC entry 3802 (class 2606 OID 18336)
-- Name: witness_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY witness
    ADD CONSTRAINT witness_pkey PRIMARY KEY (gid);


--
-- TOC entry 3647 (class 1259 OID 18339)
-- Name: idx_spatial_unit_point; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_spatial_unit_point ON spatial_unit USING gist (point);


--
-- TOC entry 3648 (class 1259 OID 18340)
-- Name: idx_spatial_unit_polygon; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_spatial_unit_polygon ON spatial_unit USING gist (polygon);


--
-- TOC entry 3557 (class 2618 OID 17051)
-- Name: geometry_columns_delete; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_delete AS ON DELETE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3555 (class 2618 OID 17049)
-- Name: geometry_columns_insert; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_insert AS ON INSERT TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3556 (class 2618 OID 17050)
-- Name: geometry_columns_update; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE geometry_columns_update AS ON UPDATE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 3803 (class 2606 OID 18341)
-- Name: business_structure_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY business
    ADD CONSTRAINT business_structure_id_fkey FOREIGN KEY (structure_id) REFERENCES spatial_unit(gid);


--
-- TOC entry 3814 (class 2606 OID 18346)
-- Name: fk_spatial_unit_gid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY structure_facility
    ADD CONSTRAINT fk_spatial_unit_gid FOREIGN KEY (structure_id) REFERENCES spatial_unit(gid) ON DELETE SET NULL;


--
-- TOC entry 3815 (class 2606 OID 18351)
-- Name: fk_ssd_social_tenure_relationship; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supporting_source_document
    ADD CONSTRAINT fk_ssd_social_tenure_relationship FOREIGN KEY (social_tenure_relationship) REFERENCES social_tenure_relationship(gid);


--
-- TOC entry 3816 (class 2606 OID 18356)
-- Name: fk_ssd_source_document; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supporting_source_document
    ADD CONSTRAINT fk_ssd_source_document FOREIGN KEY (source_document_gid) REFERENCES source_document(gid);


--
-- TOC entry 3809 (class 2606 OID 18361)
-- Name: fk_str_natural_person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY social_tenure_relationship
    ADD CONSTRAINT fk_str_natural_person FOREIGN KEY (natural_person_gid) REFERENCES natural_person(gid);


--
-- TOC entry 3810 (class 2606 OID 18366)
-- Name: fk_str_spatial_unit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY social_tenure_relationship
    ADD CONSTRAINT fk_str_spatial_unit FOREIGN KEY (spatial_unit_gid) REFERENCES spatial_unit(gid);


--
-- TOC entry 3806 (class 2606 OID 18371)
-- Name: group_person_rep_person_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY group_person
    ADD CONSTRAINT group_person_rep_person_gid_fkey FOREIGN KEY (rep_person_gid) REFERENCES natural_person(gid);


--
-- TOC entry 3807 (class 2606 OID 18376)
-- Name: group_person_sp_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY group_person
    ADD CONSTRAINT group_person_sp_unit_id_fkey FOREIGN KEY (sp_unit_id) REFERENCES spatial_unit(gid) ON DELETE CASCADE;


--
-- TOC entry 3804 (class 2606 OID 18381)
-- Name: project_area_country_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_area
    ADD CONSTRAINT project_area_country_gid_fkey FOREIGN KEY (country_gid) REFERENCES project_region(gid);


--
-- TOC entry 3805 (class 2606 OID 18386)
-- Name: project_area_country_gid_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY project_area
    ADD CONSTRAINT project_area_country_gid_fkey1 FOREIGN KEY (country_gid) REFERENCES project_region(gid);


--
-- TOC entry 3808 (class 2606 OID 18391)
-- Name: respondent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY respondent_priority
    ADD CONSTRAINT respondent_id FOREIGN KEY (res_gid) REFERENCES respondent(gid);


--
-- TOC entry 3811 (class 2606 OID 18396)
-- Name: source_document_person_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY source_document
    ADD CONSTRAINT source_document_person_gid_fkey FOREIGN KEY (person_gid) REFERENCES natural_person(gid);


--
-- TOC entry 3812 (class 2606 OID 18401)
-- Name: source_document_struct_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY source_document
    ADD CONSTRAINT source_document_struct_gid_fkey FOREIGN KEY (struct_gid) REFERENCES spatial_unit(gid);


--
-- TOC entry 3813 (class 2606 OID 18406)
-- Name: structures_settlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY structures
    ADD CONSTRAINT structures_settlement_id_fkey FOREIGN KEY (settlement_id) REFERENCES project_area(gid);


--
-- TOC entry 3817 (class 2606 OID 18411)
-- Name: witness_respondent_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY witness
    ADD CONSTRAINT witness_respondent_gid_fkey FOREIGN KEY (respondent_gid) REFERENCES respondent(gid);


--
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 10
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 1312
-- Name: valid_user(text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION valid_user(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION valid_user(text, text) FROM postgres;
GRANT ALL ON FUNCTION valid_user(text, text) TO postgres;


--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 196
-- Name: spatial_unit; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE spatial_unit FROM PUBLIC;
REVOKE ALL ON TABLE spatial_unit FROM postgres;
GRANT ALL ON TABLE spatial_unit TO postgres;
GRANT ALL ON TABLE spatial_unit TO PUBLIC;


--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 198
-- Name: admin_spatial_unit_set; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE admin_spatial_unit_set FROM PUBLIC;
REVOKE ALL ON TABLE admin_spatial_unit_set FROM postgres;
GRANT ALL ON TABLE admin_spatial_unit_set TO postgres;
GRANT ALL ON TABLE admin_spatial_unit_set TO PUBLIC;


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 204
-- Name: base_imagery; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE base_imagery FROM PUBLIC;
REVOKE ALL ON TABLE base_imagery FROM postgres;
GRANT ALL ON TABLE base_imagery TO postgres;
GRANT ALL ON TABLE base_imagery TO PUBLIC;


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 211
-- Name: check_priority_project; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_priority_project FROM PUBLIC;
REVOKE ALL ON TABLE check_priority_project FROM postgres;
GRANT ALL ON TABLE check_priority_project TO postgres;
GRANT ALL ON TABLE check_priority_project TO PUBLIC;


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 214
-- Name: check_daily_expenditure; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_daily_expenditure FROM PUBLIC;
REVOKE ALL ON TABLE check_daily_expenditure FROM postgres;
GRANT ALL ON TABLE check_daily_expenditure TO postgres;
GRANT ALL ON TABLE check_daily_expenditure TO PUBLIC;


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 215
-- Name: check_data_collector_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_data_collector_type FROM PUBLIC;
REVOKE ALL ON TABLE check_data_collector_type FROM postgres;
GRANT ALL ON TABLE check_data_collector_type TO postgres;
GRANT ALL ON TABLE check_data_collector_type TO PUBLIC;


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 216
-- Name: check_structure_extension; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_structure_extension FROM PUBLIC;
REVOKE ALL ON TABLE check_structure_extension FROM postgres;
GRANT ALL ON TABLE check_structure_extension TO postgres;
GRANT ALL ON TABLE check_structure_extension TO PUBLIC;


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 218
-- Name: check_land_owner; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_land_owner FROM PUBLIC;
REVOKE ALL ON TABLE check_land_owner FROM postgres;
GRANT ALL ON TABLE check_land_owner TO postgres;
GRANT ALL ON TABLE check_land_owner TO PUBLIC;


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 221
-- Name: check_education_level; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_education_level FROM PUBLIC;
REVOKE ALL ON TABLE check_education_level FROM postgres;
GRANT ALL ON TABLE check_education_level TO postgres;
GRANT ALL ON TABLE check_education_level TO PUBLIC;


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 222
-- Name: check_finance_option; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_finance_option FROM PUBLIC;
REVOKE ALL ON TABLE check_finance_option FROM postgres;
GRANT ALL ON TABLE check_finance_option TO postgres;
GRANT ALL ON TABLE check_finance_option TO PUBLIC;


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 224
-- Name: check_gender; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_gender FROM PUBLIC;
REVOKE ALL ON TABLE check_gender FROM postgres;
GRANT ALL ON TABLE check_gender TO postgres;
GRANT ALL ON TABLE check_gender TO PUBLIC;


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 225
-- Name: check_group_person_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_group_person_type FROM PUBLIC;
REVOKE ALL ON TABLE check_group_person_type FROM postgres;
GRANT ALL ON TABLE check_group_person_type TO postgres;
GRANT ALL ON TABLE check_group_person_type TO PUBLIC;


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 226
-- Name: check_house_shape; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_house_shape FROM PUBLIC;
REVOKE ALL ON TABLE check_house_shape FROM postgres;
GRANT ALL ON TABLE check_house_shape TO postgres;
GRANT ALL ON TABLE check_house_shape TO PUBLIC;


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 228
-- Name: check_household_relation; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_household_relation FROM PUBLIC;
REVOKE ALL ON TABLE check_household_relation FROM postgres;
GRANT ALL ON TABLE check_household_relation TO postgres;
GRANT ALL ON TABLE check_household_relation TO PUBLIC;


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 229
-- Name: check_household_tenure_status; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_household_tenure_status FROM PUBLIC;
REVOKE ALL ON TABLE check_household_tenure_status FROM postgres;
GRANT ALL ON TABLE check_household_tenure_status TO postgres;
GRANT ALL ON TABLE check_household_tenure_status TO PUBLIC;


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 232
-- Name: check_marital_status; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_marital_status FROM PUBLIC;
REVOKE ALL ON TABLE check_marital_status FROM postgres;
GRANT ALL ON TABLE check_marital_status TO postgres;
GRANT ALL ON TABLE check_marital_status TO PUBLIC;


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 233
-- Name: check_monthy_household_income; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_monthy_household_income FROM PUBLIC;
REVOKE ALL ON TABLE check_monthy_household_income FROM postgres;
GRANT ALL ON TABLE check_monthy_household_income TO postgres;
GRANT ALL ON TABLE check_monthy_household_income TO PUBLIC;


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 234
-- Name: check_montly_rent; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_montly_rent FROM PUBLIC;
REVOKE ALL ON TABLE check_montly_rent FROM postgres;
GRANT ALL ON TABLE check_montly_rent TO postgres;
GRANT ALL ON TABLE check_montly_rent TO PUBLIC;


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 235
-- Name: check_occupation; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_occupation FROM PUBLIC;
REVOKE ALL ON TABLE check_occupation FROM postgres;
GRANT ALL ON TABLE check_occupation TO postgres;
GRANT ALL ON TABLE check_occupation TO PUBLIC;


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 236
-- Name: check_owner_residence; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_owner_residence FROM PUBLIC;
REVOKE ALL ON TABLE check_owner_residence FROM postgres;
GRANT ALL ON TABLE check_owner_residence TO postgres;
GRANT ALL ON TABLE check_owner_residence TO PUBLIC;


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 238
-- Name: check_ownership_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_ownership_type FROM PUBLIC;
REVOKE ALL ON TABLE check_ownership_type FROM postgres;
GRANT ALL ON TABLE check_ownership_type TO postgres;
GRANT ALL ON TABLE check_ownership_type TO PUBLIC;


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 242
-- Name: check_previous_residence; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_previous_residence FROM PUBLIC;
REVOKE ALL ON TABLE check_previous_residence FROM postgres;
GRANT ALL ON TABLE check_previous_residence TO postgres;
GRANT ALL ON TABLE check_previous_residence TO PUBLIC;


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 244
-- Name: project_facility; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE project_facility FROM PUBLIC;
REVOKE ALL ON TABLE project_facility FROM postgres;
GRANT ALL ON TABLE project_facility TO postgres;
GRANT ALL ON TABLE project_facility TO PUBLIC;


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 246
-- Name: check_project_facility_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_project_facility_type FROM PUBLIC;
REVOKE ALL ON TABLE check_project_facility_type FROM postgres;
GRANT ALL ON TABLE check_project_facility_type TO postgres;
GRANT ALL ON TABLE check_project_facility_type TO PUBLIC;


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 249
-- Name: check_settlement_period; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_settlement_period FROM PUBLIC;
REVOKE ALL ON TABLE check_settlement_period FROM postgres;
GRANT ALL ON TABLE check_settlement_period TO postgres;
GRANT ALL ON TABLE check_settlement_period TO PUBLIC;


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 250
-- Name: check_settlement_reason; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_settlement_reason FROM PUBLIC;
REVOKE ALL ON TABLE check_settlement_reason FROM postgres;
GRANT ALL ON TABLE check_settlement_reason TO postgres;
GRANT ALL ON TABLE check_settlement_reason TO PUBLIC;


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 252
-- Name: check_social_tenure_inventory_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_social_tenure_inventory_type FROM PUBLIC;
REVOKE ALL ON TABLE check_social_tenure_inventory_type FROM postgres;
GRANT ALL ON TABLE check_social_tenure_inventory_type TO postgres;
GRANT ALL ON TABLE check_social_tenure_inventory_type TO PUBLIC;


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 253
-- Name: check_social_tenure_relationship_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_social_tenure_relationship_type FROM PUBLIC;
REVOKE ALL ON TABLE check_social_tenure_relationship_type FROM postgres;
GRANT ALL ON TABLE check_social_tenure_relationship_type TO postgres;
GRANT ALL ON TABLE check_social_tenure_relationship_type TO PUBLIC;


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 254
-- Name: check_spatial_unit_inventory_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_spatial_unit_inventory_type FROM PUBLIC;
REVOKE ALL ON TABLE check_spatial_unit_inventory_type FROM postgres;
GRANT ALL ON TABLE check_spatial_unit_inventory_type TO postgres;
GRANT ALL ON TABLE check_spatial_unit_inventory_type TO PUBLIC;


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 255
-- Name: check_spatial_unit_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_spatial_unit_type FROM PUBLIC;
REVOKE ALL ON TABLE check_spatial_unit_type FROM postgres;
GRANT ALL ON TABLE check_spatial_unit_type TO postgres;
GRANT ALL ON TABLE check_spatial_unit_type TO PUBLIC;


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 256
-- Name: check_spatial_unit_use_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_spatial_unit_use_type FROM PUBLIC;
REVOKE ALL ON TABLE check_spatial_unit_use_type FROM postgres;
GRANT ALL ON TABLE check_spatial_unit_use_type TO postgres;
GRANT ALL ON TABLE check_spatial_unit_use_type TO PUBLIC;


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 257
-- Name: check_survey_point_quality_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_survey_point_quality_type FROM PUBLIC;
REVOKE ALL ON TABLE check_survey_point_quality_type FROM postgres;
GRANT ALL ON TABLE check_survey_point_quality_type TO postgres;
GRANT ALL ON TABLE check_survey_point_quality_type TO PUBLIC;


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 258
-- Name: check_survey_point_type; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_survey_point_type FROM PUBLIC;
REVOKE ALL ON TABLE check_survey_point_type FROM postgres;
GRANT ALL ON TABLE check_survey_point_type TO postgres;
GRANT ALL ON TABLE check_survey_point_type TO PUBLIC;


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 259
-- Name: check_tenure_relationship; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_tenure_relationship FROM PUBLIC;
REVOKE ALL ON TABLE check_tenure_relationship FROM postgres;
GRANT ALL ON TABLE check_tenure_relationship TO postgres;
GRANT ALL ON TABLE check_tenure_relationship TO PUBLIC;


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 261
-- Name: check_who_responding; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_who_responding FROM PUBLIC;
REVOKE ALL ON TABLE check_who_responding FROM postgres;
GRANT ALL ON TABLE check_who_responding TO postgres;
GRANT ALL ON TABLE check_who_responding TO PUBLIC;


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 264
-- Name: check_transport_cost; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_transport_cost FROM PUBLIC;
REVOKE ALL ON TABLE check_transport_cost FROM postgres;
GRANT ALL ON TABLE check_transport_cost TO postgres;
GRANT ALL ON TABLE check_transport_cost TO PUBLIC;


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 265
-- Name: check_type_of_house; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE check_type_of_house FROM PUBLIC;
REVOKE ALL ON TABLE check_type_of_house FROM postgres;
GRANT ALL ON TABLE check_type_of_house TO postgres;
GRANT ALL ON TABLE check_type_of_house TO PUBLIC;


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 272
-- Name: project_area; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE project_area FROM PUBLIC;
REVOKE ALL ON TABLE project_area FROM postgres;
GRANT ALL ON TABLE project_area TO postgres;
GRANT ALL ON TABLE project_area TO PUBLIC;


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 273
-- Name: respondent; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE respondent FROM PUBLIC;
REVOKE ALL ON TABLE respondent FROM postgres;
GRANT ALL ON TABLE respondent TO postgres;
GRANT ALL ON TABLE respondent TO PUBLIC;


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 275
-- Name: data_collector; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE data_collector FROM PUBLIC;
REVOKE ALL ON TABLE data_collector FROM postgres;
GRANT ALL ON TABLE data_collector TO postgres;
GRANT ALL ON TABLE data_collector TO PUBLIC;


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 279
-- Name: group_party; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE group_party FROM PUBLIC;
REVOKE ALL ON TABLE group_party FROM postgres;
GRANT ALL ON TABLE group_party TO postgres;
GRANT ALL ON TABLE group_party TO PUBLIC;


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 280
-- Name: group_person; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE group_person FROM PUBLIC;
REVOKE ALL ON TABLE group_person FROM postgres;
GRANT ALL ON TABLE group_person TO postgres;
GRANT ALL ON TABLE group_person TO PUBLIC;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 282
-- Name: household; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE household FROM PUBLIC;
REVOKE ALL ON TABLE household FROM postgres;
GRANT ALL ON TABLE household TO postgres;
GRANT ALL ON TABLE household TO PUBLIC;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 286
-- Name: natural_person; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE natural_person FROM PUBLIC;
REVOKE ALL ON TABLE natural_person FROM postgres;
GRANT ALL ON TABLE natural_person TO postgres;
GRANT ALL ON TABLE natural_person TO PUBLIC;


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 302
-- Name: social_tenure_relationship; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE social_tenure_relationship FROM PUBLIC;
REVOKE ALL ON TABLE social_tenure_relationship FROM postgres;
GRANT ALL ON TABLE social_tenure_relationship TO postgres;
GRANT ALL ON TABLE social_tenure_relationship TO PUBLIC;


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 304
-- Name: source_document; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE source_document FROM PUBLIC;
REVOKE ALL ON TABLE source_document FROM postgres;
GRANT ALL ON TABLE source_document TO postgres;
GRANT ALL ON TABLE source_document TO PUBLIC;


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 308
-- Name: stdmusers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE stdmusers FROM PUBLIC;
REVOKE ALL ON TABLE stdmusers FROM postgres;
GRANT ALL ON TABLE stdmusers TO postgres;
GRANT ALL ON TABLE stdmusers TO PUBLIC;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 312
-- Name: structure_facility; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE structure_facility FROM PUBLIC;
REVOKE ALL ON TABLE structure_facility FROM postgres;
GRANT ALL ON TABLE structure_facility TO postgres;
GRANT ALL ON TABLE structure_facility TO PUBLIC;


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 315
-- Name: supporting_source_document; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE supporting_source_document FROM PUBLIC;
REVOKE ALL ON TABLE supporting_source_document FROM postgres;
GRANT ALL ON TABLE supporting_source_document TO postgres;
GRANT ALL ON TABLE supporting_source_document TO PUBLIC;


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 316
-- Name: tableroles; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE tableroles FROM PUBLIC;
REVOKE ALL ON TABLE tableroles FROM postgres;
GRANT ALL ON TABLE tableroles TO postgres;
GRANT ALL ON TABLE tableroles TO PUBLIC;


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 318
-- Name: witness; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE witness FROM PUBLIC;
REVOKE ALL ON TABLE witness FROM postgres;
GRANT ALL ON TABLE witness TO postgres;
GRANT ALL ON TABLE witness TO PUBLIC;


-- Completed on 2014-02-09 11:16:34

--
-- PostgreSQL database dump complete
--

