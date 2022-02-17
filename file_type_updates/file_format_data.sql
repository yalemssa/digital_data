SELECT CONCAT('/repositories/', dob.repo_id, '/digital_objects/', dob.id) as uri
	, fv.file_uri
	, replace(SUBSTRING_INDEX(SUBSTRING_INDEX(fv.file_uri, '.', -1), '?', 1), 'jpg', 'jpeg') as file_type
FROM file_version fv
JOIN digital_object dob on dob.id = fv.digital_object_id
WHERE (fv.file_uri like '%.jpg%'
OR fv.file_uri like '%.jpeg%'
OR fv.file_uri like '%.png%'
OR fv.file_uri like '%.gif%')
AND file_format_name_id is NULL