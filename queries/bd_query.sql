#THIS SEEMS LIKE THE BEST VERSION SO FAR
#SEARCH THE PARENT PATH???
SELECT DISTINCT CONCAT('https://archives.yale.edu/repositories/', ao.repo_id, '/archival_objects/', ao.id) as aay_url
	, CONCAT('https://archivesspace.library.yale.edu/resources/', ao.root_record_id, '#tree::archival_object_', ao.id) as staff_url
	, CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
    , replace(replace(replace(replace(replace(identifier, ',', ''), '"', ''), ']', ''), '[', ''), 'null', '') AS call_number
	, replace(resource.title, '"', "'") as resource_title
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
	, CONCAT('/repositories/', do.repo_id, '/digital_objects/', do.id) as do_uri
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
WHERE (ev.value like '%CD%'
		OR ev.value like '%DVD%'
		OR ev.value like '%disk%'
		OR ev.value like '%disc%'
		OR ev.value like '%bytes%'
		OR ev.value like '%drives%'
		OR ev.value like '%computer%'
		#OR ev.value like '%video%' 
		OR ev2.value like '%computer%'
		OR cp.name like '%CD%' 
		or cp.name like '%compact%' 
		or cp.name like '%DV%' 
		or cp.name like '%disc%'
		or resource.title like '%disc%'
		#OR ao.display_string like '%digital %'
		#OR ao.display_string like '%digitized%'
		OR ao.display_string like '%computer files%'
		or ao.display_string like '%disk%'
		or ao.display_string like '%disc%')
		#THIS TAKES TOO LONG...UNFORTUNATELY IT'D BE REALLY USEFUL...
		#or TREEPATH(ao.id) like '%audio%'
		#or TREEPATH(ao.id) like '%born digital%'
		#see what happens if I remove this...
		#AND resource.identifier NOT LIKE '%HM%'
		#AND resource.title NOT like '%Phi Beta Kappa%'
		#AND resource.title NOT LIKE 'Arabic film poster collection'
		#AND resource.title NOT LIKE 'Japanese film ephemera collection'
		#AND resource.title NOT LIKE '%Filmer Stuart Cuckow%'
		#AND resource.title NOT LIKE '%Holocaust Testimonies records%'
		#AND resource.title NOT LIKE '%Librarian, Yale University records%'
		#AND resource.title NOT LIKE '%Testimonies collection of related documents and ephemera%'
		#AND ao.display_string NOT LIKE '%Claudio%'
		#taking this out leads to some false negatives
		-- AND ao.display_string not like '%correspondence%'
		#and resource.title not like '%microfilm%'
		#AND resource.title not like '%microform%'
		#AND ao.display_string not like '%microfilm%'
		#AND (cp.name not like '%microfilm%' OR cp.name is NULL))
#I'm wondering if this erroneously includes some materials...need to try to add it into the statement above?
#but I thought that's how I had problems in the first place. but at least I'd be able to compare...
#Going to create a v5 and move these...
AND (fv.file_uri not like '%https://aviaryplatform.com/images/audio-default.png%'
		OR fv.file_uri is NULL)
AND ao.repo_id = 12
GROUP BY ao.id