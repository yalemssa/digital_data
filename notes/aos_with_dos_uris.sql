SELECT DISTINCT ao.id as uri
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