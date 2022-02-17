SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(replace(replace(replace(resource.title, '"', "'"), '</', ''), '<', ''), '>', '') as resource_title
	, replace(replace(replace(replace(ao.title, '"', "'"), '</', ''), '<', ''), '>', '') as ao_title
	, replace(replace(replace(replace(ao2.title, '"', "'"), '</', ''), '<', ''), '>', '') as parent_ao_title
	, ao.create_time
	, fv.file_uri
FROM digital_object do
JOIN file_version fv on fv.digital_object_id = do.id
LEFT JOIN instance_do_link_rlshp idlr on idlr.digital_object_id = do.id
LEFT JOIN instance on idlr.instance_id = instance.id
LEFT JOIN archival_object ao on instance.archival_object_id = ao.id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
LEFT JOIN resource on ao.root_record_id = resource.id
WHERE fv.id is not null
AND do.repo_id = 12
AND ao.id is not null
AND fv.file_uri not like '%130.132.21.20%'
AND fv.file_uri not like '%https://drive.google.com/drive/u/0/folders%'
AND resource.title not like '%Kissinger%'