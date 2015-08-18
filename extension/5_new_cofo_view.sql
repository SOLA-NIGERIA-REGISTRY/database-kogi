﻿
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.3
-- Dumped by pg_dump version 9.3.1
-- Started on 2015-08-06 17:13:32

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = administrative, pg_catalog;

--
-- TOC entry 3731 (class 0 OID 682221)
-- Dependencies: 381
-- Data for Name: ba_unit_detail_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

DELETE FROM condition_type  where is_for = 'cofo';


ALTER TABLE ba_unit_detail_type DISABLE TRIGGER ALL;
DELETE FROM ba_unit_detail_type;
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('plot', 'Plot Number', 'Plot number', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('block', 'Block', 'Block', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('plan', 'Layout Plan', 'Layout Plan', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('zone', 'Zone', 'Zonal areas', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('location', 'Location', 'Location of the property', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('lga', 'LGA', 'Lga', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('estate', 'Estate', 'Estate type', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('yearsTodevelope', 'Years to develope', 'Within the specified number of years the piece of land has to be developed by erecting buildings or other works', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('valueTodevelope', 'Value of the buildings/other works', 'the value of the buildings to be erected or the additional works to be completed in the specified period of time', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('term', 'Term of Occupancy', 'The term the occupancy will last', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('revperiod', 'Review Period', 'The divided period of term of occupancy', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('startdate', 'Date Commenced', 'Date in which the occupancy started', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('purpose', 'Occupancy Right Purpose', 'Purpose of Occupancy', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('dateissued', 'Date Signed', 'Date when governor signed', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('rent', 'Yearly Rent', 'Amount of yearly rent', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('advpayment', 'Advance Payment', 'Payment in advance', 'c', 'cofo');
INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for) VALUES ('instrnum', 'Instrument Number', 'The number of the CofO  Register', 'c', 'cofo');



ALTER TABLE ba_unit_detail_type ENABLE TRIGGER ALL;

-- Completed on 2015-08-06 17:13:32

--
-- PostgreSQL database dump complete
--





--- METADATA AND SETTINGS  

insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'date', '?? DATE ??');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'sheet-number', '?? NW, SE, SW');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'resolution', '?? 50 cm ??');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'data-source', '?? DATUM ??');

insert into system.setting(name, vl, active, description) values('surveyor', '??', true, 'Name of Surveyor');
insert into system.setting(name, vl, active, description) values('surveyorRank', '??', true, 'The rank of the Surveyor');
--insert into system.setting(name, vl, active, description) values('state', 'Katsina', true, 'the state');
--insert into system.setting(name, vl, active, description) values('featureFloatFront', 'images/sola/front_float.svg', true, 'svg for the floating element in front page');
--insert into system.setting(name, vl, active, description) values('featureFloatBack', 'images/sola/back_float.svg', true, 'svg for the floating element in back page');
--insert into system.setting(name, vl, active, description) values('featureFront', 'images/sola/front.svg', true, 'svg for the background element in front page');
--insert into system.setting(name, vl, active, description) values('featureBack', 'images/sola/back.svg', true, 'svg for the background element in back page');

















-- DROP FUNCTION administrative.get_parcel_share(character varying);

CREATE OR REPLACE FUNCTION administrative.get_parcel_share(baunit_id character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  rrr character varying;
  i integer =0 ;
BEGIN
  rrr = '';
             

	for rec in 
              select  (rrrt.display_value)  as tiporrr,
              initcap(pp.name)||' '||initcap(pp.last_name) || ' ( '||rrrsh.nominator||'/'||rrrsh.denominator||' )'
               as value,
               rrrsh.nominator||'/'||rrrsh.denominator as shareFraction
              from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr,
		     administrative.rrr_share  rrrsh,
		     administrative.rrr_type  rrrt
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and rrrsh.id = pr.share_id
		AND rrr.type_code = rrrt.code
		and   rrr.ba_unit_id= baunit_id
	loop
           rrr = rrr || ', ' || rec.value;
           i = i+1;
	end loop;

        if rrr = '' then
	  rrr = 'No rrr claimed ';
       end if;

        
	if substr(rrr, 1, 1) = ',' then
          rrr = substr(rrr,2);
        end if;
        if i = 2 then
          rrr= replace(rrr, '( 1/1 )','Joint');
        end if;
        if i > 2 then
          rrr= replace(rrr, '( 1/1 )','Undevided Share');
        end if;
        rrr= replace(rrr, '( 1/1 )','');
return rrr;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_parcel_share(character varying)
  OWNER TO postgres;
---------------------------------------------------------------------------

-- DROP FUNCTION administrative.get_baunit_detail(ba_unit_id character varying, detail_code character varying , is_for character varying);

CREATE OR REPLACE FUNCTION administrative.get_baunit_detail(ba_unit_id character varying, detail_code character varying , is_for character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  result character varying;
  i integer =0 ;
BEGIN
  result = '';
             

	SELECT bud.custom_detail_text 
	INTO result
	FROM cdministrative.ba_unit_detail bud
	WHERE bud.ba_unit_id = ba_unit_id 
	AND bud.detail_code = detail_code
	AND bud.is_for = is_for;

        if result = '' then
	  result = 'No Result ';
        end if;
return result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_baunit_detail(character varying, character varying, character varying)
  OWNER TO postgres;



-- DROP FUNCTION administrative.get_rrr_detail(ba_unit_id character varying, detail_code character varying, is_for character varying);

CREATE OR REPLACE FUNCTION administrative.get_rrr_detail(ba_unit_id character varying, detail_code character varying, is_for character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  result character varying;
  i integer =0 ;
BEGIN
  result = '';
             

	SELECT rrrd.custom_detail_text 
	INTO result
	FROM administrative.rrr_detail rrrd,
	     administrative.rrr rrr
	WHERE 
	     rrr.ba_unit_id  = ba_unit_id
        AND 
	     rrr.type_code = 'ownership' 
	AND 
	     rrrd.rrr_id = rrr.id 
	AND 
	     rrrd.detail_code = detail_code
	AND 
	     rrrd.is_for = is_for;

        if result = '' then
	  result = 'No Result ';
        end if;
return result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_rrr_detail(character varying, character varying, character varying)
  OWNER TO postgres;







---------------------------------------------------------------------------
-- DROP VIEW application.systematic_registration_certificates;
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
  SELECT DISTINCT 
    
--	TBV  ------------------------------------------------------------------------------------------
--    sg.name::text 									AS name, 
--    aa.nr 										AS nr, 
--    aa.id::text 									AS appid, 
--    ( SELECT lga.label
--           FROM cadastre.spatial_unit_group lga
--          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) 	AS ward, 
--    (( SELECT count(s.id) AS count
--           FROM source.source s
--           WHERE s.description::text ~~ 
--           ((('TOTAL_'::text || 'title'::text) || '%'::text) 
--           || replace(sg.name::text, '/'::text, '-'::text))))::integer 			AS cofo, 

--------------------------------------------------------------------------------------------------------

    co.id											AS id, 
    co.name_firstpart										AS name_firstpart, 
    co.name_lastpart										AS name_lastpart, 
    su.ba_unit_id										AS ba_unit_id, 
    round(sa.size) 										AS size, 
    administrative.get_parcel_share(su.ba_unit_id) 						AS owners, 

--	SYSTEM.SETTING TABLE
--	system.setting.system_id
    ( SELECT setting.vl
             from system.setting
             WHERE setting.name::text = 'system-id'::text) 					AS state, 
          
-- 	system.setting.surveyor
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyor'::text) 						AS surveyor, 


--	system.setting.rank
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyorRank'::text) 					AS rank,



--	SYSTEM.CONFIG_MAP_LAYER_METADATA TABLE

-- 	imagerydate
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'date'::text) 				AS imagerydate, 
--	imageryresolution
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'resolution'::text) 			AS imageryresolution, 
--	imagerysource
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'data-source'::text) 			AS imagerysource, 


--    	BA UNIT DETAIL TABLE
--   	 lga 
    administrative.get_baunit_detail(su.ba_unit_id, 'lga', 'cofo') 				AS lga, 

--   	 zone 
    administrative.get_baunit_detail(su.ba_unit_id, 'zone', 'cofo') 				AS zone, 

--   	 location 
    administrative.get_baunit_detail(su.ba_unit_id, 'location', 'cofo') 			AS location, 

--    	 plan        
    administrative.get_baunit_detail(su.ba_unit_id, 'plan', 'cofo') 				AS plan, 

-- 	 sheetnr  
    administrative.get_baunit_detail(su.ba_unit_id, 'sheetnr', 'cofo') 				AS sheetnr, 

-- 	 date commenced
    administrative.get_baunit_detail(su.ba_unit_id, 'startdate', 'cofo')  			AS commencingdate, 

--  	 purpose     
    administrative.get_baunit_detail(su.ba_unit_id, 'purpose', 'cofo')   			AS purpose, 

--  	 term     
    administrative.get_baunit_detail(su.ba_unit_id, 'term', 'cofo')	              		AS term,

--       rent
    administrative.get_baunit_detail(su.ba_unit_id, 'rent', 'cofo')	              		AS  rent

   FROM 
    --- cadastre.spatial_unit_group sg, 
    cadastre.cadastre_object co, 
    administrative.ba_unit bu, 
    -- cadastre.land_use_type lu, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su 
    --application.application_property ap, 
    --application.application aa, 
    --application.service s

  WHERE 
  --- sg.hierarchy_level = 5 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND 
  --(co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) 
  --AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
  -- TBU  
  --AND s.request_type_code::text = 'systematicRegn'::text 
  -- AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text)
  -- AND 
  bu.id::text = su.ba_unit_id::text
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  -- TBU  
  --AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------
-- DROP VIEW cadastre.parcel_plan ;
CREATE OR REPLACE VIEW cadastre.parcel_plan AS 
  SELECT DISTINCT 
    
--	TBV  ------------------------------------------------------------------------------------------
--    sg.name::text 									AS name, 
--    aa.nr 										AS nr, 
--    aa.id::text 									AS appid, 
--    ( SELECT lga.label
--           FROM cadastre.spatial_unit_group lga
--          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) 	AS ward, 
--    (( SELECT count(s.id) AS count
--           FROM source.source s
--           WHERE s.description::text ~~ 
--           ((('TOTAL_'::text || 'title'::text) || '%'::text) 
--           || replace(sg.name::text, '/'::text, '-'::text))))::integer 			AS cofo, 

--------------------------------------------------------------------------------------------------------

    co.name_firstpart, 
    co.name_lastpart, 
    co.id, 
    su.ba_unit_id, 
    round(sa.size) 										AS size, 
    administrative.get_parcel_share(su.ba_unit_id) 						AS owners, 

--	SYSTEM.SETTING TABLE
--	system.setting.system_id
    ( SELECT setting.vl
             from system.setting
             WHERE setting.name::text = 'system-id'::text) 					AS state, 
          
-- 	system.setting.surveyor
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyor'::text) 						AS surveyor, 


--	system.setting.rank
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyorRank'::text) 					AS rank,



--	SYSTEM.CONFIG_MAP_LAYER_METADATA TABLE

-- 	imagerydate
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'date'::text) 				AS imagerydate, 
--	imageryresolution
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'resolution'::text) 			AS imageryresolution, 
--	imagerysource
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'data-source'::text) 			AS imagerysource, 


--    	BA UNIT DETAIL TABLE
--   	 lga 
    administrative.get_baunit_detail(su.ba_unit_id, 'lga', 'cofo') 				AS lga, 

--   	 zone 
    administrative.get_baunit_detail(su.ba_unit_id, 'zone', 'cofo') 				AS zone, 

--   	 location 
    administrative.get_baunit_detail(su.ba_unit_id, 'location', 'cofo') 			AS proplocation, 

--    	 plan        
    administrative.get_baunit_detail(su.ba_unit_id, 'plan', 'cofo') 				AS title, 

-- 	 sheetnr  
    administrative.get_baunit_detail(su.ba_unit_id, 'sheetnr', 'cofo') 				AS sheetnr, 

-- 	 date commenced
    administrative.get_baunit_detail(su.ba_unit_id, 'startdate', 'cofo')  			AS commencingdate, 

--  	 purpose     
    administrative.get_baunit_detail(su.ba_unit_id, 'purpose', 'cofo')   			AS landuse, 

--  	 term     
    administrative.get_baunit_detail(su.ba_unit_id, 'term', 'cofo')	              		AS term,

--       rent
    administrative.get_baunit_detail(su.ba_unit_id, 'rent', 'cofo')	              		AS  rent

   FROM 
    --- cadastre.spatial_unit_group sg, 
    cadastre.cadastre_object co, 
    administrative.ba_unit bu, 
    -- cadastre.land_use_type lu, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su 
    --application.application_property ap, 
    --application.application aa, 
    --application.service s

  WHERE 
  --- sg.hierarchy_level = 5 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND 
  --(co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) 
  --AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
  -- TBU  
  --AND s.request_type_code::text = 'systematicRegn'::text 
  -- AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text)
  -- AND 
  bu.id::text = su.ba_unit_id::text
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  -- TBU  
  --AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;
-------------------------------------------------------------------------------------------------