SELECT CONCAT('/repositories/', ao.repo_id, '/archival_obects/', ao.id) as uri
	, ev.value as extent_type
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.content')) as `note_text`
	, npi.persistent_id
FROM archival_object ao
LEFT JOIN note on note.archival_object_id = ao.id
LEFT JOIN extent on extent.archival_object_id = ao.id
LEFT JOIN enumeration_value ev on ev.id = extent.extent_type_id
LEFT JOIN note_persistent_id npi on npi.note_id = note.id
WHERE note.notes like '%physdesc%'
AND extent.id is not null
AND ao.repo_id = 12