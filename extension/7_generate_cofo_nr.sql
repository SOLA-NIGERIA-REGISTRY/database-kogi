-- Sequence: administrative.cofo_nr_seq

DROP SEQUENCE administrative.cofo_nr_seq;

CREATE SEQUENCE administrative.cofo_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 509
  CACHE 1
  CYCLE;
ALTER TABLE administrative.cofo_nr_seq
  OWNER TO postgres;
COMMENT ON SEQUENCE administrative.cofo_nr_seq
  IS 'Sequence number used as the basis for the CofO numbering. This sequence is used by the generate-cofo-nr business rule.';


delete from system.br_definition where br_id = 'generate-cofo-nr';
delete from system.br where id = 'generate-cofo-nr';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-cofo-nr', 'generate-cofo-nr', 'sql', '...::::::::...::::::::::::::::...::::::::...', NULL, '');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('generate-cofo-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.cofo_nr_seq''), ''0000'')) AS vl');
