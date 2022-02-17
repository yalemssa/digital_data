SELECT *
FROM (SELECT CONCAT('https://archives.yale.edu/repositories/', ao1.repo_id, '/archival_objects/', ao1.id) as aay_url
    , ANY_VALUE(CONCAT(ah.resource_note_text, ' > ', ah.path)) as access_note_hierarchy
    , GROUP_CONCAT(DISTINCT CONCAT(IF(extent.number is not NULL, extent.number, ""), ' ', IF(ev3.value is not NULL, ev3.value,""))) as extent
    , replace(replace(replace(replace(replace(resource.identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
    , resource.title as collection_title
    , ANY_VALUE(hierarchies.full_path) as archival_object_hierarchy
	, replace(ao1.display_string, '"', "'") as archival_object_title
	, GROUP_CONCAT(DISTINCT CONCAT(IF(ev.value IS NOT NULL, ev.value, '')
                                                        , ' '
                                                        , IF(tc.indicator IS NOT NULL, tc.indicator, '')
                                                        , ' ['
                                                        , IF(cp.name IS NOT NULL, cp.name, '')
                                                        , '], '
                                                        , IF(ev2.value IS NOT NULL, ev2.value, '')
                                                        , ' '
                                                        , IF(sc.indicator_2 IS NOT NULL, sc.indicator_2, 'NULL'))
						ORDER BY CAST(tc.indicator as UNSIGNED), CAST(sc.indicator_2 as UNSIGNED)
						SEPARATOR '; ') as physical_containers
    , do_uri
    , do_title
    , dobject_id
    , file_uris
    , ANY_VALUE(note_text) as note_text
FROM archival_object ao1
LEFT JOIN (SELECT GROUP_CONCAT(CONCAT('/repositories/', do.repo_id, '/digital_objects/', do.id) SEPARATOR '; ') as do_uri
					, GROUP_CONCAT(do.title SEPARATOR '; ') as do_title
                    , GROUP_CONCAT(do.digital_object_id SEPARATOR '; ') as dobject_id
                    , GROUP_CONCAT(file_uri SEPARATOR '; ') as file_uris
                    , ao.id as ao_id
				FROM digital_object do
				LEFT JOIN file_version fv on fv.digital_object_id = do.id
                JOIN instance_do_link_rlshp idlr on idlr.digital_object_id = do.id
                JOIN instance on instance.id = idlr.instance_id
                JOIN archival_object ao on ao.id = instance.archival_object_id
				WHERE do.repo_id = 12
				AND fv.file_uri like '%preservica%'
                GROUP BY ao.id) as dobject_subtable on dobject_subtable.ao_id = ao1.id
JOIN (SELECT ao.id as ao_id
        , GROUP_CONCAT(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.subnotes[0].content')) SEPARATOR '; ') as note_text
        FROM archival_object ao
        LEFT JOIN note on note.archival_object_id = ao.id
        WHERE note.notes like '%otherfindaid%'
        GROUP by ao.id
        UNION ALL
        SELECT ao_id
            , 'NA' as note_text
        FROM (SELECT ao.id as ao_id
            , GROUP_CONCAT(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.type[0]')) separator ', ') as `note_type`
        FROM archival_object ao
        LEFT JOIN note on note.archival_object_id = ao.id
        GROUP BY ao.id) as note_table
        WHERE (note_table.note_type is NULL or note_table.note_type not like '%otherfindaid%')) otherfindaids on otherfindaids.ao_id = ao1.id
JOIN resource on resource.id = ao1.root_record_id
LEFT JOIN instance on instance.archival_object_id = ao1.id
LEFT JOIN sub_container sc on sc.instance_id = instance.id
LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
LEFT JOIN top_container tc on tc.id = tclr.top_container_id
LEFT JOIN top_container_profile_rlshp tcpr on tcpr.top_container_id = tc.id
LEFT JOIN container_profile cp on tcpr.container_profile_id = cp.id
LEFT JOIN enumeration_value ev on ev.id = tc.type_id
LEFT JOIN enumeration_value ev2 on ev2.id = sc.type_2_id
LEFT JOIN extent on extent.archival_object_id = ao1.id
LEFT JOIN enumeration_value ev3 on ev3.id = extent.extent_type_id
LEFT JOIN hierarchies on ao1.id = hierarchies.id
LEFT JOIN accesshierarchies ah on ao1.id = ah.ao_id
LEFT JOIN note on note.archival_object_id = ao1.id
WHERE ao1.repo_id = 12
AND do_title is not null
GROUP BY ao1.id) as results
-- WHERE (extent like '%audio%' 
-- 				OR extent like '%video%'
--                 OR extent like '%film%'
--                 OR extent like '%CD%'
--                 OR extent like '%sound%'
--                 OR extent like '%record%'
--                 OR extent like '%cassette%'
--                 OR LOWER(extent) like '%dvd%'
--                 OR extent like '%JAZ%'
--                 OR extent like '%xd%'
--                 OR (extent like '%reels%' and physical_containers not like '%microfilm%'))
#GROUP BY results.ao1_id