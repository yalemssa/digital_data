SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', note.archival_object_id) as uri
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.content[0]')) as `note_text`
FROM note
JOIN archival_object ao on ao.id = note.archival_object_id
where note.notes like '%physdesc%'
and (note.notes like '%minutes%' or note.notes like '%Run%')
and ao.repo_id = 12