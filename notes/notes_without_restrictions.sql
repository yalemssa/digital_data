SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, npi.persistent_id
	, note.notes
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')) as note_text
	, ao.root_record_id
FROM archival_object ao
JOIN note on note.archival_object_id = ao.id
JOIN note_persistent_id npi on npi.note_id = note.id
WHERE note.notes like '%accessrestrict%'
AND note.notes like '%Digital access%'
AND note.notes not like '%RestrictedFragile%'
AND ao.repo_id = 12
