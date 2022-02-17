SELECT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, ANY_VALUE(npi.persistent_id) as persistent_id
	, ANY_VALUE(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content'))) as note_text
    , resource.title as resource_title
    , ao.display_string as ao_title
    , GROUP_CONCAT(do.title SEPARATOR ', ') as dig_objs
    , ANY_VALUE(ev.value) as extent_type
from note
JOIN archival_object ao on ao.id = note.archival_object_id
JOIN resource on resource.id = ao.root_record_id
JOIN note_persistent_id npi on npi.note_id = note.id
LEFT JOIN instance on instance.archival_object_id = ao.id
LEFT JOIN instance_do_link_rlshp idlr on idlr.instance_id = instance.id
LEFT JOIN digital_object do on do.id = idlr.digital_object_id
LEFT JOIN extent on extent.archival_object_id = ao.id
LEFT JOIN enumeration_value ev on ev.id = extent.extent_type_id
WHERE note.notes like '%Contact Public Services (phone: 203 432-1735, e-mail:%'
GROUP BY ao.id