#!/usr/bin/python3

from ast import literal_eval
from utilities import utilities as u
from utilities import db
import requests
import json
import pprint
import traceback
import logging
from tqdm import tqdm


#NOTE - check on whether some of the ANALOG/NO_EXTENT stuff has incorrect notes now...
# To do this get a report of the ANALOG/NO_EXTENT note and then get a report of extent types linked to those...

#TO-DO:
# Figure out access restriction inheritance query
# Clean up functions
# Write update CSV back to Google sheet
# Process for including the physical box in the query...

def run_query(query_string):
	'''Asks for user to input path to query, opens query and returns it as a string'''
	try:
		dbconn = db.DBConn(config_file="/Users/aliciadetelich/Dropbox/git/aspace_tools/aspace_tools/as_tools_config.yml")
		results, header_row = dbconn.run_query_list(query_string)
	finally:
		dbconn.close_conn()
		return results, header_row

def compare_lists(materials_q_results, notes_q_results):
	note_ids = [int(row[0]) for row in notes_q_results]
	material_ids = [int(row[0]) for row in materials_q_results]
	diff_list = [row for row in material_ids if row not in note_ids]
	return str(diff_list).replace('[', '(').replace(']', ')')

def get_new_data(materials_q_fp, notes_q_fp, full_materials_q_fp):
	'''This gets everything that doesn't already have a note but has at least one digital object with a file URI'''
	q_suffix = f"""AND ao.id in {compare_lists(materials_q_fp, notes_q_fp)}
	GROUP BY ao.id"""
	full_query = f"""{full_materials_q_fp} {q_suffix}"""
	results, header_row = run_query(full_query)
	#convert into a list...maybe put this in the db.py file
	results = [list(row) for row in results]
	return results, header_row

def process_new_data(results):
	'''Maybe move this loop somewhere else and then do some additonal post-processing with the combine_preservica_do_titles function'''
	for row in results:
		extent_cp = row[7]
		file_uris = row[12]
		if extent_cp == 'NULL, NULL':
			row[7] = "ANALOG/NO_EXTENT"
		if ('computer' in extent_cp 
			or 'disk'  in extent_cp 
			or 'disc' in extent_cp
			or 'drives' in extent_cp
			or 'bytes' in extent_cp
			or 'DV' in extent_cp
			or 'CD' in extent_cp
			or 'XD' in extent_cp
			or 'compact' in extent_cp):
			row[7] = "BD"
		if ('cassette' in extent_cp
			or 'reel' in extent_cp
			or 'film' in extent_cp
			or 'audio' in extent_cp
			or 'phonograph' in extent_cp
			or 'sound' in extent_cp
			or 'video' in extent_cp
			or 'record' in extent_cp
			or 'matic' in extent_cp):
			row[7] = "DIGITIZED_AV"
		#this will override things that may be one of the above but are also online
		if ('aviary' in file_uris or 'http://hdl.handle.net/10079/digcoll/' in file_uris):
			row[7] = "ONLINE"
			row[12] = process_online_helper(row[12])
		elif ('aviary' not in file_uris and 'http://hdl.handle.net/10079/digcoll/' not in file_uris):
			row[11] = combine_preservica_do_titles(row[11])
			#there are a handful of Kissinger things here...
	return results

def combine_preservica_do_titles(row):
	#add a natural sort here
	if 'Preservica' in row:
		preservica_uris = set(row.split(', '))
		if len(preservica_uris) > 1:
			preservica_uris_sorted = sorted(preservica_uris)
			row = f"{preservica_uris_sorted[0]}-{preservica_uris_sorted[-1]}"
	return row


def process_online_helper(file_uri):
	'''Might want to have this happen earlier so can check the results...'''
	uri_list = [row for row in set(file_uri.split(', ')) if 'preservica' not in row]
	if len(uri_list) == 1:
		return uri_list[0]
	else:
		#need error handling here
		print(uri_list)
		return uri_list[0]

# Note creation process is below. Still need to automate data extraction

def create_note(text, note_type):
    return {'jsonmodel_type': 'note_multipart',
                'publish': True,
                'subnotes': [{'content': text,
                          'jsonmodel_type': 'note_text',
                          'publish': True}],
            'type': note_type}

#count combine these functions?

def process_born_digital(digital_object_title, record_json):
	born_digital_access = f"""As a preservation measure, original materials may not be used. Digital access copies must be provided for use. Contact Manuscripts and Archives at <ref actuate="onRequest" show="new" href="mailto:mssa.assist@yale.edu?subject=Digital Copy Request: {digital_object_title}.">mssa.assist@yale.edu</ref> to request access."""
	new_access_note = create_note(born_digital_access, 'accessrestrict')
	record_json['notes'].append(new_access_note)
	return record_json

def process_analog(digital_object_title, record_json):
	analog_alt_form = f"""A copy of this material is available in digital form from Manuscripts and Archives. Contact Manuscripts and Archives at <ref actuate="onRequest" show="new" href="mailto:mssa.assist@yale.edu?subject=Digital Copy Request: {digital_object_title}">mssa.assist@yale.edu</ref> to request access to the digital copy."""
	new_altform_note = create_note(analog_alt_form, 'altformavail')
	record_json['notes'].append(new_altform_note)
	return record_json

def process_av(digital_object_title, record_json):
	av_alt_form_not_online = f"""A copy of this material is available in digital form from Manuscripts and Archives."""
	digitized_av_access = f"""As a preservation measure, original materials, as well as preservation and duplicating masters, may not be used. Digital access copies must be provided for use. Contact Manuscripts and Archives at <ref actuate="onRequest" show="new" href="mailto:mssa.assist@yale.edu?subject=Digital Copy Request: {digital_object_title}">mssa.assist@yale.edu</ref> to request access."""
	new_access_note = create_note(digitized_av_access, 'accessrestrict')
	new_altform_note = create_note(av_alt_form_not_online, 'altformavail')
	record_json['notes'].extend([new_access_note, new_altform_note])
	return record_json

def process_online(file_uri, record_json):
	file_uris = process_online_helper(file_uri)
	digitized_in_access_system = f"""A copy of this material is available in digital form from Manuscripts and Archives and <ref actuate="onRequest" show="new" href="{file_uri}">online</ref>."""
	new_altform_note = create_note(digitized_in_access_system, 'altformavail')
	record_json['notes'].append(new_altform_note)
	return record_json

#will have three different lists depending on what's in column C - ANALOG/NO_EXTENT, BD, DIGITIZED_AV
def process_file(csvfile, dirpath, rowcount, api_url, headers):
	with tqdm(total=rowcount) as pbar:
		for row in csvfile:
			try:
				pbar.update(1)
				record_json = requests.get(api_url + row['uri'], headers=headers).json()
				u.create_backups(dirpath, row['uri'], record_json)
				if row['category'] == "ANALOG/NO_EXTENT":
					record_json = process_analog(row['preservica_title'], record_json)
				if row['category'] == "BD":
					record_json = process_born_digital(row['preservica_title'], record_json)
				if row['category'] == "DIGITIZED_AV":
					record_json = process_av(row['preservica_title'], record_json)
				if row['category'] == "ONLINE":
					record_json = process_online(row['file_uri'], record_json)
				record_post = requests.post(api_url + row['uri'], headers=headers, json=record_json).json()
				#print(record_post)
				logging.debug(record_post)
				if 'error' in record_post:
					logging.debug(row['uri'])
					logging.debug(record_post.get('error'))
			except Exception:
				logging.debug(row['uri'])
				logging.debug(traceback.format_exc())

def main():
	u.error_log('/Users/aliciadetelich/Dropbox/git/mssa_digital_data_projects/digital_access_note_workflow/error_log.log')
	all_notes_with_links_query, header_1 = run_query(open('existing_note_uris.sql', 'r', encoding='utf8').read())
	materials_query, header_2 = run_query(open('aos_with_dos_uris.sql', 'r', encoding='utf8').read())
	full_materials_query = open('partial_material_query.sql', 'r', encoding='utf8').read()
	query_results, query_headers = get_new_data(materials_query, all_notes_with_links_query, full_materials_query)
	processed_data = process_new_data(query_results)
	fp = 'outfile_final.csv'
	fileobject, csvoutfile = u.opencsvout(fp)
	csvoutfile.writerow(query_headers)
	csvoutfile.writerows(processed_data)
	fileobject.close()
	dirpath = "/Users/aliciadetelich/Dropbox/git/mssa_digital_data_projects/digital_access_note_workflow/data/backups"
	#need to do something if they don't want to continue.
	continue_eh = input('Check your data and press any key to continue, press Q to quit: ')
	if continue_eh != 'Q':
		rowcount = sum(1 for line in open(fp).readlines()) - 1
		csvfile = u.opencsvdict(fp)
		#do a config_file thing here.
		api_url, headers = u.login()
		process_file(csvfile, dirpath, rowcount, api_url, headers)

if __name__ == "__main__":
	main()