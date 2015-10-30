----   update in source.administrative_source_type
UPDATE source.administrative_source_type
   SET display_value='Diagram'
 WHERE code='cadastralSurvey';
 
 
INSERT INTO version (version_num) VALUES ('1511a');