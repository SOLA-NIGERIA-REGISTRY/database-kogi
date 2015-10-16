DELETE FROM system.config_map_layer_metadata  where name_layer = 'orthophoto' and "name" = 'sheet-number';

INSERT INTO administrative.ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('IntellMapSheet', 'Sheet Number', 'Sheet Number', 'c', 'plan', 'TEXT', 16);




---------------------------------------------------------------------------
--DROP VIEW application.systematic_registration_certificates;
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
             WHERE setting.name::text = 'state'::text) 					AS state, 
          
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
    administrative.get_baunit_detail(su.ba_unit_id, 'LGA') 				AS lga, 

--   	 zone 
    administrative.get_baunit_detail(su.ba_unit_id, 'zone') 				AS zone, 

--   	 location 
    administrative.get_baunit_detail(su.ba_unit_id, 'location') 			AS location, 

--    	 plan        
    administrative.get_baunit_detail(su.ba_unit_id, 'layoutPlan') 				AS plan, 

-- 	 sheetnr  
    administrative.get_baunit_detail(su.ba_unit_id, 'IntellMapSheet') 				AS sheetnr, 

-- 	 date commenced
    administrative.get_baunit_detail(su.ba_unit_id, 'dateCommenced')  			AS commencingdate, 

--  	 purpose     
    administrative.get_baunit_detail(su.ba_unit_id, 'cOfOtype')   			AS purpose, 

--  	 term     
    administrative.get_baunit_detail(su.ba_unit_id, 'term')	              		AS term,

--       rent
    administrative.get_baunit_detail(su.ba_unit_id, 'yearlyRent')	              		AS  rent

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
    administrative.get_baunit_detail(su.ba_unit_id, 'LGA') 				AS lga, 

--   	 zone 
    administrative.get_baunit_detail(su.ba_unit_id, 'zone') 				AS zone, 

--   	 location 
    administrative.get_baunit_detail(su.ba_unit_id, 'location') 			AS proplocation, 

--    	 plan        
    administrative.get_baunit_detail(su.ba_unit_id, 'layoutPlan') 				AS title, 

-- 	 sheetnr  
    administrative.get_baunit_detail(su.ba_unit_id, 'IntellMapSheet') 				AS sheetnr, 

-- 	 date commenced
    administrative.get_baunit_detail(su.ba_unit_id, 'dateCommenced')  			AS commencingdate, 

--  	 purpose     
    administrative.get_baunit_detail(su.ba_unit_id, 'cOfOtype')   			AS landuse, 

--  	 term     
    administrative.get_baunit_detail(su.ba_unit_id, 'term')	              		AS term,

--       rent
    administrative.get_baunit_detail(su.ba_unit_id, 'yearlyRent')	              		AS  rent

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
