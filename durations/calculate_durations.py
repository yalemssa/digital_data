#!/usr/bin/python3

from collections import defaultdict
import datetime
import time

from utilities import utilities as u


def generate_timedict():
	header_row, csvfile = u.opencsv('/Users/aliciadetelich/Dropbox/git/aspace_preservica_db/db_data/third_ingest/durations_matched_pt2_ready.csv')
	timedict = defaultdict(list)
	for row in csvfile:
		uri = row[0]
		duration = row[1]
		timedict[uri].append(duration)
	return timedict

def sum_times(time_list):
	total = datetime.timedelta()
	strptimes = [time.strptime(item, "%H:%M:%S") for item in time_list]
	for duration in strptimes:
		total = total + datetime.timedelta(hours=duration.tm_hour, minutes=duration.tm_min, seconds=duration.tm_sec)
	return total



def main():
	try:
		fileobject, csvoutfile = u.opencsvout('/Users/aliciadetelich/Dropbox/git/aspace_preservica_db/db_data/third_ingest/durations_summed_2.csv')
		csvoutfile.writerow(['uri', 'duration'])
		time_data = generate_timedict()
		for key, value in time_data.items():
			total_time = sum_times(value)
			print(key, value, total_time)
			csvoutfile.writerow([key, total_time])
	finally:
		fileobject.close()


if __name__ == "__main__":
	main()