SELECT DISTINCT CONCAT('https://archives.yale.edu/repositories/', ao.repo_id, '/archival_objects/', ao.id) as aay_url
	, CONCAT('https://archivesspace.library.yale.edu/resources/', ao.root_record_id, '#tree::archival_object_', ao.id) as staff_url
	, CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
    , replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'") as resource_title
    , TREEPATH(ao.id) as `parent_path`
	, replace(replace(ao.display_string, '"', "'"), ",", "\,") as ao_title
    , ev.value as extent_type
    , cp.name as  container_profile
FROM archival_object ao
JOIN resource on resource.id = ao.root_record_id
LEFT JOIN extent on extent.archival_object_id = ao.id
LEFT JOIN instance on instance.archival_object_id = ao.id
LEFT JOIN instance_do_link_rlshp idlr on instance.id = idlr.instance_id
LEFT JOIN sub_container sc on sc.instance_id = instance.id
LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
LEFT JOIN top_container tc on tclr.top_container_id = tc.id
LEFT JOIN top_container_profile_rlshp tcpr on tcpr.top_container_id = tc.id
LEFT JOIN container_profile cp on tcpr.container_profile_id = cp.id
LEFT JOIN enumeration_value ev on ev.id = extent.extent_type_id
LEFT JOIN enumeration_value ev2 on ev2.id = instance.instance_type_id
LEFT JOIN enumeration_value ev3 on ev3.id = tc.type_id
LEFT JOIN enumeration_value ev4 on ev4.id = sc.type_2_id
WHERE ao.repo_id = 12
AND (ev.id is NULL AND cp.id is not NULL)
AND cp.name NOT IN ('chest', 'envelope', 'microfilm box', 'painting')
AND cp.name not like '%archive%'
and cp.name not like '%card_box%'
and cp.name not like '%custom%'
and cp.name not like '%flat%'
and cp.name not like '%flip%'
and cp.name not like '%folder%'
and cp.name not like '%legacy%'
and cp.name not like '%object%'
and cp.name not like '%paige%'
and cp.name not like '%tube%'