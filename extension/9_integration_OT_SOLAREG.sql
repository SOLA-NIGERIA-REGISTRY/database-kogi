----   update in source.administrative_source_type
UPDATE source.administrative_source_type
   SET display_value='Diagram'
 WHERE code='cadastralSurvey';



----- update to make dynamic form labels in sola registry as in opentenure
ALTER TABLE administrative.ba_unit_detail
   ALTER COLUMN detail_code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail.detail_code IS 'The type of detail.';

ALTER TABLE administrative.ba_unit_detail_historic
   ALTER COLUMN detail_code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail_historic.detail_code IS 'The type of detail.';

ALTER TABLE administrative.ba_unit_detail_type
   ALTER COLUMN code TYPE character varying(255);
COMMENT ON COLUMN administrative.ba_unit_detail_type.code IS 'The code for the detail type.';


UPDATE administrative.ba_unit_detail_type  SET code='advancePayment' WHERE code='advpayment';
UPDATE administrative.ba_unit_detail_type  SET code='cOfO' WHERE code='cofonum';
UPDATE administrative.ba_unit_detail_type  SET code='dateSigned' WHERE code='dateissued';
UPDATE administrative.ba_unit_detail_type  SET code='dateRegistered' WHERE code='dateregistered';
UPDATE administrative.ba_unit_detail_type  SET code='instrumentRegistrationNo' WHERE code='instrnum';
UPDATE administrative.ba_unit_detail_type  SET code='LGA' WHERE code='lga';
UPDATE administrative.ba_unit_detail_type  SET code='layoutPlan' WHERE code='plan';
UPDATE administrative.ba_unit_detail_type  SET code='plotNum' WHERE code='plot';
UPDATE administrative.ba_unit_detail_type  SET code='cOfOtype' WHERE code='purpose';
UPDATE administrative.ba_unit_detail_type  SET code='yearlyRent' WHERE code='rent';
UPDATE administrative.ba_unit_detail_type  SET code='reviewPeriod' WHERE code='revperiod';
UPDATE administrative.ba_unit_detail_type  SET code='dateCommenced' WHERE code='startdate';


----- update to make dynamic form labels in sola registry as in opentenure
UPDATE administrative.ba_unit_detail  SET detail_code='advancePayment' WHERE detail_code='advpayment';
UPDATE administrative.ba_unit_detail  SET detail_code='cOfO' WHERE detail_code='cofonum';
UPDATE administrative.ba_unit_detail  SET detail_code='dateSigned' WHERE detail_code='dateissued';
UPDATE administrative.ba_unit_detail  SET detail_code='dateRegistered' WHERE detail_code='dateregistered';
UPDATE administrative.ba_unit_detail  SET detail_code='instrumentRegistrationNo' WHERE detail_code='instrnum';
UPDATE administrative.ba_unit_detail  SET detail_code='LGA' WHERE detail_code='lga';
UPDATE administrative.ba_unit_detail  SET detail_code='layoutPlan' WHERE detail_code='plan';
UPDATE administrative.ba_unit_detail  SET detail_code='plotNum' WHERE detail_code='plot';
UPDATE administrative.ba_unit_detail  SET detail_code='cOfOtype' WHERE detail_code='purpose';
UPDATE administrative.ba_unit_detail  SET detail_code='yearlyRent' WHERE detail_code='rent';
UPDATE administrative.ba_unit_detail  SET detail_code='reviewPeriod' WHERE detail_code='revperiod';
UPDATE administrative.ba_unit_detail  SET detail_code='dateCommenced' WHERE detail_code='startdate';


UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=17
 WHERE code='estate';

UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=18
 WHERE code='zone';

UPDATE administrative.ba_unit_detail_type
   SET  status='c',
       order_view=16
 WHERE code='LGA';

UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=19
 WHERE code='IntellMapSheet';

UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=20
 WHERE code='instrumentRegistrationNo';

UPDATE system.setting 
   SET vl = 'KT'
 WHERE name = 'system-id'
  