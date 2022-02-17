SELECT value as event_type
FROM
enumeration_value ev
JOIN enumeration on enumeration.id = ev.enumeration_id
WHERE enumeration.name like '%event_event_type%'