INSERT INTO system.approle (code, display_value, status, description) VALUES ('ViewReports', 'View Community Server reports', 'c', 'View Community Server reports');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ViewReports', 'super-group-id', '2c4da65a-43f6-11e5-9c67-9f326dbd1cf8', 1, 'i', 'db:postgres', '2015-08-16 15:07:08.677');



UPDATE application.request_type
   SET  display_value='Capture Existing CofO'
 WHERE code='regnOnTitle';

UPDATE application.request_type
   SET  display_value='New CofO'
 WHERE code='newFreehold';


UPDATE administrative.rrr_type
   SET  display_value='Statutory Right of Occupancy'
 WHERE code ='ownership';
