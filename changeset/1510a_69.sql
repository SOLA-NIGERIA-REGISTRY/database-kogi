UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=16
 WHERE code='estate';

UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=17
 WHERE code='zone';

UPDATE administrative.ba_unit_detail_type
   SET  status='x',
       order_view=18
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
   SET vl = 'KG'
 WHERE name = 'system-id'
  