SELECT *
from archival_object ao
where (LOWER(ao.title) like '%digital record%' or LOWER(ao.title) like '%born digital%' or  LOWER(ao.title) like '%electronic record%' or LOWER(ao.title) like '%born-digital%')
and ao.repo_id = 12