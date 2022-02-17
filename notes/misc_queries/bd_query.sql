SELECT DISTINCT CONCAT('/repositories/', ao.repo_id, '/archival_objects/', ao.id) as uri
	, replace(resource.title, '"', "'") as resource_title
	, replace(ao.display_string, '"', "'") as ao_title
	, ev.value as extent_type
#	, do.title
#	, cp.name
#	, tc.indicator
	, fv.file_uri
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
WHERE (ev.value in ('audio belts', 
					'audio cartridges', 
					'audio discs', 
					'audio discs (CD)',
					'audio rolls', 
					'audio_cylinders', 
					'audio_discs_(CD)', 
					'audio_wire_reels', 
					'audiocassettes',
					'audiotape_reels', 
					'audiotapes', 'film reel (35mm)', 
					'film reels (16 mm)', 
					'film reels (8mm)',
					'film rolls', 
					'film_cartridges', 
					'film_cassettes', 
					'film_loops', 
					'film_reels', 
					'filmslips',
					'filmstrip cartridges', 
					'filmstrips', 
					'microcassettes', 
					'orb disk', 
					'phonograph_records',
					'sound_cartridges', 
					'sound_track_film_reels', 
					'super 8 film', 
					'3.5_floppy_disks', 
					'5.25_floppy_disks', 
					'CD-RWs', 
					'CD-Rs', 
					'DVD-RWs', 
					'DVD-Rs', 
					'JAZ_disks', 
					'ZIP_disks', 
					'disks' , 
					'external_hard_drives', 
					'flash_drives', 
					'floppy disks',
					'gigabytes', 
					'internal_hard_drives', 
					'megabytes', 
					'optical disc (xdcam)', 
					'optical disks (dvd)',
					'terabytes') 
		OR ev.value like '%computer%'
		OR ev.value like '%video%' 
		OR cp.name like '%audio%' 
		OR cp.name like '%CD%' 
		or cp.name like '%compact%' 
		or cp.name like '%DV%' 
		or (cp.name like '%film%' and cp.name not like '%microfilm%') 
		or cp.name like '%cassette%' 
		or cp.name like '%record%' 
		or cp.name like '%matic%' 
		or cp.name like '%video%' 
		or cp.name like '%XD%' 
		or ao.title like '%audio%' 
		or ao.title like '%recording%' 
		or ao.title like '%cassette%' 
		or ao.title like '%video%' 
		or ao.title like '%vhs%' 
		or (ao.title like '%use cop%' and cp.name not like '%microfilm%') 
		or (tc.indicator like '%U%' and cp.name not like '%microfilm%') 
		or (ev.value like '%reels%' and cp.name not like '%microfilm%'))
AND (fv.file_uri is NULL 
		or fv.file_uri not like '%https://aviaryplatform.com/images/audio-default.png%')
AND ao.repo_id = 12