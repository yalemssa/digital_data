select CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')) as note_text
	, note.create_time
    , note.created_by
    , note.last_modified_by
    , note.user_mtime
FROM note
JOIN archival_object ao on ao.id = note.archival_object_id
WHERE (note.notes like '%mailto:mssa.assist@yale.edu?subject=Digital Copy Request%'
    OR note.notes like '%A copy of this material is available in digital form from Manuscripts and Archives and%')
AND note.create_time > '2020-03-21 00:00:00'
ORDER BY note.create_time DESC