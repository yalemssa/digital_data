#THIS SEEMS LIKE THE BEST VERSION SO FAR
#SEARCH THE PARENT PATH???
SELECT DISTINCT CONCAT('https://archives.yale.edu/repositories/', ao.repo_id, '/archival_objects/', ao.id) as aay_url
	, CONCAT('https://archivesspace.library.yale.edu/resources/', ao.root_record_id, '#tree::archival_object_', ao.id) as staff_url
	, CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
    , replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'") as resource_title
    , TREEPATH(ao.id) as `parent_path`
	, replace(replace(ao.display_string, '"', "'"), ",", "\,") as ao_title
	, ANY_VALUE(CONCAT(
							IF(ev.value is not NULL,
								 ev.value,
								 "NULL"),
                                 ', ', 
                            IF(cp.name is not NULL,
								 cp.name,
								 "NULL"))
                            ) as extent_type_container_profile
	, ANY_VALUE(do.title) as do_title
	, GROUP_CONCAT(fv.file_uri SEPARATOR ', ') as file_uris
-- 	, ANY_VALUE(JSON_UNQUOTE(JSON_EXTRACT(CAST(CONVERT(note.notes using utf8) as json), '$.content'))) as `note_text`
FROM archival_object ao
JOIN resource on resource.id = ao.root_record_id
LEFT JOIN extent on extent.archival_object_id = ao.id
LEFT JOIN enumeration_value ev on ev.id = extent.extent_type_id
LEFT JOIN instance on instance.archival_object_id = ao.id
LEFT JOIN instance_do_link_rlshp idlr on instance.id = idlr.instance_id
LEFT JOIN sub_container sc on sc.instance_id = instance.id
LEFT JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
LEFT JOIN top_container tc on tclr.top_container_id = tc.id
LEFT JOIN top_container_profile_rlshp tcpr on tcpr.top_container_id = tc.id
LEFT JOIN container_profile cp on tcpr.container_profile_id = cp.id
LEFT JOIN digital_object do on idlr.digital_object_id = do.id
LEFT JOIN enumeration_value ev2 on ev2.id = instance.instance_type_id
LEFT JOIN file_version fv on fv.digital_object_id = do.id
LEFT JOIN enumeration_value ev3 on ev3.id = tc.type_id
LEFT JOIN enumeration_value ev4 on ev4.id = sc.type_2_id
#join instance type?
-- LEFT JOIN note on note.archival_object_id = ao.id
-- WHERE note.notes like '%physdesc%'
WHERE ((ev.value like '%audio%'
		OR ev.value like '%film%'
		OR ev.value like '%cassette%'
		OR ev.value like '%phonograph%'
		OR ev.value like '%sound%'
		OR ev.value like '%video%' 
		or (ev.value like '%reel%' and cp.name not like '%microfilm%')
		OR (ev3.value like '%reel%' and cp.name not like '%microfilm')
		OR (ev4.value like '%reel%' and cp.name not like '%microfilm%')
		OR extent.container_summary like '%recording%'
		OR extent.container_summary like '%video%'
		OR extent.container_summary like '%film%'
		or extent.container_summary like '%audio%'
		or extent.container_summary like '%vhs%'
		or extent.container_summary like '% sound%'
		or extent.container_summary like '%beta%'
		OR cp.name like '%audio%' 
		or cp.name like '%compact%' 
		or (cp.name like '%film%' and cp.name not like '%microfilm%') 
		or cp.name like '%cassette%' 
		or cp.name like '%record%' 
		or cp.name like '%matic%' 
		or cp.name like '%video%' 
		or cp.name like '%XD%'
		#this adds something like 6k results - this may include many false positives
		or resource.title like '%recording%'
		or resource.title like '%video%'
		or resource.title like '%film%'
		or resource.title like '%audio%'
		or resource.title like '%vhs%'
		or resource.title like '%sound%'
		OR ao.display_string like '%digital %'
		OR ao.display_string like '%digitized%'
		or ao.display_string like '%audio%' 
		or ao.display_string like '%recording%' 
		or ao.display_string like '%cassette%' 
		or ao.display_string like '%video%' 
		or ao.display_string like '%vhs%'
		or ao.display_string like '% sound%'
		#THIS TAKES TOO LONG...UNFORTUNATELY IT'D BE REALLY USEFUL...
		#or TREEPATH(ao.id) like '%audio%'
		#or TREEPATH(ao.id) like '%born digital%'
		or (ao.display_string like '%beta%' and ao.display_string not like '%Phi Beta Kappa%')
		or (ao.display_string like '%use cop%' and cp.name not like '%microfilm%')
		#see what happens if I remove this...
		or (tc.indicator like '%U%' and cp.name not like '%microfilm%'))
		AND resource.identifier NOT LIKE '%HM%'
		AND resource.title NOT like '%Phi Beta Kappa%'
		AND resource.title NOT LIKE 'Arabic film poster collection'
		AND resource.title NOT LIKE 'Japanese film ephemera collection'
		AND resource.title NOT LIKE '%Filmer Stuart Cuckow%'
		AND resource.title NOT LIKE '%Holocaust Testimonies records%'
		AND resource.title NOT LIKE '%Librarian, Yale University records%'
		AND resource.title NOT LIKE '%Testimonies collection of related documents and ephemera%'
		AND ao.display_string NOT LIKE '%Claudio%'
		#taking this out leads to some false negatives
		-- AND ao.display_string not like '%correspondence%'
		and resource.title not like '%microfilm%'
		AND resource.title not like '%microform%'
		AND ao.display_string not like '%microfilm%'
		AND (cp.name not like '%microfilm%' OR cp.name is NULL))
#I'm wondering if this erroneously includes some materials...need to try to add it into the statement above?
#but I thought that's how I had problems in the first place. but at least I'd be able to compare...
#Going to create a v5 and move these...
AND (fv.file_uri not like '%https://aviaryplatform.com/images/audio-default.png%'
		OR fv.file_uri is NULL)
AND ao.repo_id = 12
GROUP BY ao.id