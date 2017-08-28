# adapted from: https://stackoverflow.com/questions/7529538/create-kml-from-csv-in-python
# to multiple lon-lat coordinates into the coordinate tag
# (https://gis.stackexchange.com/questions/210403/converting-spatialpoints-to-normal-for-exporting-csv)

import csv
#Input the file name.
fname = raw_input("Enter file name WITHOUT extension: ")
data = csv.reader(open(fname + '.csv'), delimiter = ',')
#Skip the 1st header row.
data.next()
#Open the file to be written.
f = open('csv2kml.kml', 'w')

#Writing the kml file.
f.write("<?xml version='1.0' encoding='UTF-8'?>\n")
f.write("<kml xmlns='http://earth.google.com/kml/2.1'>\n")
f.write("<Document>\n")
f.write("   <name>" + fname + '.kml' +"</name>\n")
for row in data:
    f.write("   <Placemark>\n")
    f.write("       <name>" + str(row[6]) + "</name>\n")
    f.write("       <Point>\n")
    f.write("           <coordinates>" + str(row[1]) + "," + str(row[2]) + "," + str(row[3]) +  "," + str(row[4]) + "</coordinates>\n")
    f.write("       </Point>\n")
    f.write("   </Placemark>\n")
f.write("</Document>\n")
f.write("</kml>\n")
print "File Created. "
print "Press ENTER to exit. "
raw_input()
f.close()
