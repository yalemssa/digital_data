SELECT CONCAT('/repositories/', ao.repo_id) as repository
  , CONCAT('/repositories/', ao.repo_id, '/resources/', ao.root_record_id) as resource
  , CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as archival_object_uri
  , replace(replace(replace(replace(replace(resource.identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
  , replace(resource.title, '"', "'") as resource_title
  , hierarchies.full_path
  , replace(ao2.title, '"', "'") as parent_title
  , replace(ao.title, '"', "'") as ao_title
  , dob_instances.do_ids
  , dob_instances.do_titles
  , dob_instances.file_uris
  , dob_instances.dob_instance_types
  , phys_instances.tc_indicators
  , phys_instances.sc_indicators
  , phys_instances.phys_instance_types
  , phys_instances.cps
  , phys_instances.tc_types
  , phys_instances.sc_types
  , physdescs.notes
  , extent_table.extent_numbers
  , extent_table.extent_types
  , extent_table.extent_portions
  , extent_table.extent_summaries
  , ao.create_time
FROM archival_object ao
JOIN resource on resource.id = ao.root_record_id
LEFT JOIN hierarchies on hierarchies.id = ao.id
LEFT JOIN archival_object ao2 on ao2.id = ao.parent_id
#digital object instances
LEFT JOIN (SELECT instance.archival_object_id as ao_id
      , GROUP_CONCAT(do.id SEPARATOR '; ') as do_ids
      , GROUP_CONCAT(do.title SEPARATOR '; ') as do_titles
      , GROUP_CONCAT(IFNULL(fv.file_uri, 'NULL') SEPARATOR '; ') as file_uris
      , GROUP_CONCAT(ev2.value SEPARATOR '; ') as dob_instance_types
    FROM instance
    JOIN instance_do_link_rlshp idlr on instance.id = idlr.instance_id
    LEFT JOIN digital_object do on idlr.digital_object_id = do.id
    LEFT JOIN enumeration_value ev2 on ev2.id = instance.instance_type_id
    LEFT JOIN file_version fv on fv.digital_object_id = do.id
    GROUP BY instance.archival_object_id
    ) as dob_instances on dob_instances.ao_id = ao.id
#physical instances with container profiles
LEFT JOIN (SELECT instance.archival_object_id as ao_id
      , GROUP_CONCAT(tc.indicator SEPARATOR '; ') as tc_indicators
      , GROUP_CONCAT(IFNULL(sc.indicator_2, 'NULL') SEPARATOR '; ') as sc_indicators
      , GROUP_CONCAT(ev2.value SEPARATOR '; ') as phys_instance_types
      , GROUP_CONCAT(IFNULL(cp.name, 'NULL') SEPARATOR '; ') as cps
      , GROUP_CONCAT(IFNULL(ev3.value, 'NULL') SEPARATOR '; ') as tc_types
      , GROUP_CONCAT(IFNULL(ev4.value, 'NULL') SEPARATOR '; ') as sc_types
    FROM instance
    LEFT JOIN sub_container sc on sc.instance_id = instance.id
    LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
    LEFT JOIN top_container tc on tclr.top_container_id = tc.id
    LEFT JOIN top_container_profile_rlshp tcpr on tcpr.top_container_id = tc.id
    LEFT JOIN container_profile cp on tcpr.container_profile_id = cp.id
    LEFT JOIN enumeration_value ev2 on ev2.id = instance.instance_type_id
    LEFT JOIN enumeration_value ev3 on ev3.id = tc.type_id
    LEFT JOIN enumeration_value ev4 on ev4.id = sc.type_2_id
    GROUP BY instance.archival_object_id
    ) as phys_instances on phys_instances.ao_id = ao.id
# physdesc notes
LEFT JOIN (SELECT note.archival_object_id as ao_id
      , GROUP_CONCAT(DISTINCT JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.content')) SEPARATOR '; ') as notes
    FROM note
    WHERE note.notes like '%physdesc%'
    GROUP BY note.archival_object_id) as physdescs on physdescs.ao_id = ao.id
# extents
LEFT JOIN (SELECT extent.archival_object_id as ao_id
      , GROUP_CONCAT(extent.number SEPARATOR '; ') as extent_numbers
      , GROUP_CONCAT(ev.value SEPARATOR '; ') as extent_types
      , GROUP_CONCAT(ev2.value SEPARATOR '; ') as extent_portions
      , GROUP_CONCAT(extent.container_summary SEPARATOR '; ') as extent_summaries
    FROM extent
    LEFT JOIN enumeration_value ev on ev.id = extent.extent_type_id
    LEFT JOIN enumeration_value ev2 on ev2.id = extent.portion_id
    GROUP BY extent.archival_object_id) as extent_table on extent_table.ao_id = ao.id
WHERE (# many of MSSA's born-digital files have a card box or microfilm box as the container profile. This
       # won't retrieve any of that. Check whether the instance type is computer disks/tapes in these instances
        (phys_instances.cps like '%CD%' or phys_instances.cps like '%DVD%'
            or phys_instances.cps like '%disc%' or phys_instances.cps like '%compact%')
        OR (phys_instances.phys_instance_types like '%computer%')
        OR (ao.title like '%computer%' OR ao.title like '%disk%' or ao.title like '%discs%' or ao.title like '%hard drive%'
            or ao.title like '%floppy drive%')
        -- OR (ao2.title like '%computer%' OR ao.title like '%disk%' or ao.title like '%discs%')
        or (hierarchies.full_path like '%computer%' OR hierarchies.full_path like '%disk%' or hierarchies.full_path like '%discs%')
        OR (resource.title like '%discs%' or resource.title like '%disks%')
        OR (physdescs.notes like '%computer%' or physdescs.notes like '%disk%' or physdescs.notes like '%disc%' or physdescs.notes like '%drive%')
        -- OR phys_instances.tc_types IS NOT NULL
        -- OR phys_instances.sc_types IS NOT NULL
        -- OR physdescs.notes IS NOT NULL
        OR (extent_table.extent_types like '%CD%' or extent_table.extent_types like '%DVD%' or extent_table.extent_types like '%disk%'
              OR extent_table.extent_types like '%disc%' or extent_table.extent_types like '%bytes%' or extent_table.extent_types like '%drive%'
              OR extent_table.extent_types like '%computer%')
        )
# needs to have an instance
AND (phys_instances.phys_instance_types is not null OR dob_instances.dob_instance_types is not null)
AND (phys_instances.sc_types not like '%folder%')
AND resource.title not like '%Manual Collection%'
AND hierarchies.full_path not like '%microcomputer%'
AND hierarchies.full_path not like '%duplicating master%'
AND hierarchies.full_path not like '%videotapes%'
AND lower(ao.title) not like '%computerized systems%'
AND lower(ao.title) not like '%computer lab%'
AND lower(ao.title) not like '%computer room%'
AND lower(ao.title) not like '%computer rm%'
AND lower(ao.title) not like '%computer support%'
AND lower(ao.title) not like '%use cop%'
AND lower(ao.title) not like '%computer orientation%'
AND lower(ao.title) not like '%computer instructions%'
AND lower(ao.title) not like '%computer printout%'
AND lower(ao.title) not like '%computer center%'
AND lower(ao.title) not like '%computer card%'
AND lower(ao.title) not like '%computer manual%'
AND lower(ao.title) not like '%record copy%'
AND lower(ao.title) not like '%phonograph%'
AND lower(ao2.title) not like '%computer support%'
AND lower(ao2.title) not like '%computer orientation%'
AND lower(ao2.title) not like '%computer instructions%'
AND lower(ao2.title) not like '%computer center%'
AND lower(ao2.title) not like '%computer printout%'
AND lower(ao2.title) not like '%computer manual%'
AND lower(ao2.title) not like '%computer card%'
AND lower(ao2.title) not like '%use cop%'
AND lower(ao2.title) not like '%vinyl sound discs%'
AND lower(ao2.title) not like '%phonograph%'
AND lower(ao2.title) not like '%videocassette%'
AND ao.repo_id not in (6, 7)