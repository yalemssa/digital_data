# Digital access note workflow

The following tasks are included in this preliminary process for adding notes to archival objects which are represented in Preservica or an online access system such as Aviary or Find-It:
1. Queries the ArchivesSpace database to retrieve URIs of materials which already have digital access notes of the types defined below
2. Queries the ArchivesSpace database to retrieve URIs of archival objects which have  linked digital object with at least one file URI
3. Compares the results and queries the database to return all archival objects which have a linked digital object but do not have a digital access note
4. Processes the query data to categorize materials by whether they are a.) digitized A/V in Preservica but not in an access system. b.) born-digital material in Preservica but not an access system, analog material in Preservica but not an access system, or material of any of these types in an access system.
5. If there is more than one Preservica digital object associated with an archival object, generate a string with the first and last item in the list of digital objects (i.e.), for use in the note
6. Process the "ONLINE" data to retrieve the URLs for online access system, for use in the note
7. Use processed data to create the appropriate note - the script uses the category column to determine which note to create, and inserts either the Preservica title (or title range) into an email subject line (if in Preservica but not online), or inserts a link to the item's record in an online access system.
8. Generates an updated report for use by PS staff and others

<!-- TO-DO - add access restriction data using recursive queries -->


## Requirements

* Python 3.6+ - see `requirements.txt` for required modules
* Access to API and MySQL database

## Note text

The following notes are created as part of this workflow:

For born-digital materials not in an online access system, but in Preservica:

`accessrestrict` note text: As a preservation measure, original materials may not be used. Digital access copies must be provided for use. Contact Manuscripts and Archives at <ref actuate="onRequest" show="new" href="mailto:mssa.assist@yale.edu?subject=Digital Copy Request: {digital_object_title}.">mssa.assist@yale.edu</ref> to request access

For analog materials not in an online access system, but in Preservica:

For A/V materials not in an online access system, but in Preservica:

For any material type in an online access system:


<!--
General process:
	1.) Get report of things with Preservica digital objects but nothing in an access system
          -Could use the av_bd query and filter by new things and search the group_concated - check if all the things I added notes to are in the list..
          -Need to be able to distinguish by analog/bd/av
            ....


	2.) Get a report of things in an access system
	3.) Prep report for Google Drive with tree information, restriction information, etc.
			-Use the TREEPATH function to get tree info;
			-Do I also want to distinguish between Born-Digital and AV. Not sure how I did tht before...

 -->



<!-- Note: not currently worrying about whether something is restricted or not. I put that in the first report but probably don't need to recreate that in the first pass. Would be useful in the future though, especially now that I have a better method for retrieving parent data. Also should try using the ordered records endpoint again....

How could I use the recursion stuff that's in the TREEPATH function to retrieve access notes; I think it should be straightforward.

-->
