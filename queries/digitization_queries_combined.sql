#QUERY 1: GET USE COPY AND COMPUTER FILES ARCHIVAL OBJECTS
SELECT #CONCAT('/repositories/', tc.repo_id, '/top_containers/', tc.id) as tc_uri
	CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
#	, tc.indicator as indicator
#	, tc.barcode as barcode
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'")
	, replace(ao.title, '"', "'")
	, replace(ao2.title, '"', "'") as parent_ao_title
	, ao.create_time
	, '1' as q_num
FROM archival_object ao
LEFT JOIN instance on instance.archival_object_id = ao.id
LEFT JOIN sub_container sc on sc.instance_id = instance.id
LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
LEFT JOIN top_container tc on tclr.top_container_id = tc.id
LEFT JOIN resource on resource.id = ao.root_record_id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
WHERE (LOWER(ao.title) like '%use cop%' or LOWER(ao.title) like '%computer files%')
AND ao.repo_id = 12
UNION
#QUERY 2: GET ALL "U" TOP CONTAINER INDICATORS
SELECT #CONCAT('/repositories/', tc.repo_id, '/top_containers/', tc.id) as tc_uri
	CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
#	, tc.indicator as indicator
#	, tc.barcode as barcode
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'")
	, replace(ao.title, '"', "'")
	, replace(ao2.title, '"', "'") as parent_ao_title
	, ao.create_time
	, '2' as q_num
FROM top_container tc
LEFT JOIN top_container_link_rlshp tclr on tclr.top_container_id = tc.id
LEFT JOIN sub_container sc on sc.id = tclr.sub_container_id
LEFT JOIN instance on instance.id = sc.instance_id
LEFT JOIN archival_object ao on ao.id = instance.archival_object_id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
LEFT JOIN resource on resource.id = ao.root_record_id
WHERE tc.repo_id = 12
AND resource.identifier not like '%HM%'
AND (tc.indicator like '%U' OR tc.indicator like 'U%')
UNION
#QUERY 3: GET PRESERVICA NOTES IN ARCHIVAL OBJECT RECORDS
SELECT #CONCAT('/repositories/', tc.repo_id, '/top_containers/', tc.id) as tc_uri
	CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
#	, tc.indicator as indicator
#	, tc.barcode as barcode
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'")
	, replace(ao.title, '"', "'")
	, replace(ao2.title, '"', "'") as parent_ao_title
	, ao.create_time
	, '3' as q_num
FROM archival_object ao
LEFT JOIN note on note.archival_object_id = ao.id
LEFT JOIN instance on instance.archival_object_id = ao.id
LEFT JOIN sub_container sc on sc.instance_id = instance.id
LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
LEFT JOIN top_container tc on tclr.top_container_id = tc.id
LEFT JOIN resource on resource.id = ao.root_record_id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
WHERE LOWER(note.notes) like '%preservica%'
AND ao.repo_id = 12
UNION
#QUERY 4: GET ARCHIVAL OBJECTS WITH LINKED PRESERVICA DIGITAL OBJECTS
select #concat('/repositories/', do.repo_id, '/digital_objects/', do.id) as tc_uri
	CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
#	, do.title as indicator
#	, NULL as barcode
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'")
	, replace(ao.title, '"', "'")
	, replace(ao2.title, '"', "'") as parent_ao_title
	, ao.create_time
	, '4' as q_num
FROM digital_object do
LEFT JOIN instance_do_link_rlshp idlr on idlr.digital_object_id = do.id
LEFT JOIN instance on idlr.instance_id = instance.id
LEFT JOIN archival_object ao on instance.archival_object_id = ao.id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
LEFT JOIN resource on ao.root_record_id = resource.id
where do.title like '%[Preservica]%'
and do.repo_id = 12
UNION
#QUERY 5: GET FILE VERSIONS (DO LINKS, I GUESS?)
SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'")
	, replace(ao.title, '"', "'")
	, replace(ao2.title, '"', "'") as parent_ao_title
	, ao.create_time
	, '5' as q_num
FROM digital_object do
JOIN file_version fv on fv.digital_object_id = do.id
LEFT JOIN instance_do_link_rlshp idlr on idlr.digital_object_id = do.id
LEFT JOIN instance on idlr.instance_id = instance.id
LEFT JOIN archival_object ao on instance.archival_object_id = ao.id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
LEFT JOIN resource on ao.root_record_id = resource.id
WHERE fv.id is not null
AND do.repo_id = 12