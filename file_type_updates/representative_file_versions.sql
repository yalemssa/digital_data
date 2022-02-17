SELECT CONCAT('/repositories/', dob.repo_id, '/digital_objects/', dob.id) as uri 
	, fv.file_uri
	, fv.is_representative
	, ev.value as file_format_name
FROM file_version fv
JOIN digital_object dob on fv.digital_object_id = dob.id
LEFT JOIN enumeration_value ev on ev.id = fv.file_format_name_id
WHERE (fv.file_uri like '%.jpg%' 
		OR fv.file_uri like '%.jpeg%' 
		or fv.file_uri like '%.png%' 
		OR fv.file_uri like '%.gif%' 
		OR fv.file_uri like '%.iiif%')