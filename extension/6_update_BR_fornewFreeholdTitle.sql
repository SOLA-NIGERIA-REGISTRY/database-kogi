delete from system.br_definition  WHERE br_id = 'application-approve-cancel-old-titles';
delete from system.br_validation  WHERE br_id = 'application-approve-cancel-old-titles';
delete from system.br WHERE id = 'application-approve-cancel-old-titles';


--- MUST BE A CANCEL TITLE IN THE APPLICATION FOR THE PARENT
UPDATE system.br_definition
   SET  body= 
'WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE 
				se.application_id = #{id}	AND 
				se.request_type_code = ''newFreehold''),
	parent_titles	AS	((SELECT DISTINCT ON (ba.id) ba.id AS liveTitle
				FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE 
				s.application_id = #{id} AND 
				ba.status_code = ''pending''))
				SELECT CASE WHEN (fhCheck IS TRUE AND (SELECT COUNT(liveTitle) FROM parent_titles) > 0) 
				THEN (SELECT COUNT(id) FROM application.service sv 
					WHERE 
					sv.application_id = #{id} AND 
					sv.request_type_code = ''cancelProperty'') > 0
				ELSE null
				END AS vl FROM newFreeholdApp'
 WHERE br_id = 'application-for-new-title-has-cancel-property-service';








