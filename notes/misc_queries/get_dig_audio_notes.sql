SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, replace(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')), '"', "'") as `note_text`
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.type[0]')) as `note_type`
FROM note
JOIN archival_object ao on ao.id = note.archival_object_id
WHERE ao.repo_id = 12
AND note.notes like '%note_multipart%'
AND (note.notes like '%digit%' OR '%audio%')
UNION ALL
SELECT CONCAT('/repositories/', resource.repo_id, '/resources/', resource.id) as uri
	, replace(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')), '"', "'")
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.type[0]')) as `note_type`
FROM note
JOIN resource on resource.id = note.resource_id
WHERE resource.repo_id = 12
AND note.notes like '%note_multipart%'
AND (note.notes like '%digit%' OR '%audio%')
UNION ALL
SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, replace(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')), '"', "'")
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.type[0]')) as `note_type`
FROM note
JOIN archival_object ao on ao.id = note.archival_object_id
WHERE ao.repo_id = 12
AND note.notes like '%note_singlepart%'
AND (note.notes like '%digit%' OR '%audio%')
UNION ALL
SELECT CONCAT('/repositories/', resource.repo_id, '/resources/', resource.id) as uri
	, replace(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')), '"', "'")
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.type[0]')) as `note_type`
FROM note
JOIN resource on resource.id = note.resource_id
WHERE resource.repo_id = 12
AND note.notes like '%note_singlepart%'
AND (note.notes like '%digit%' OR '%audio%')