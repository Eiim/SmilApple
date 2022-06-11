import re

smilText = """<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="512pt" height="384pt" viewBox="0 0 512 384">
<defs>
<animate xmlns="http://www.w3.org/2000/svg" xlink:href="#frame" xmlns:xlink="http://www.w3.org/1999/xlink" attributeName="d" values=\""""

frames = 6573;
framerate = 30;

lastPath = "";

for i in range(1,frames+1):
	f = open("svgs/"+str(i)+".svg", "r")
	svgText = f.read()
	paths = "".join(re.findall("d=\"([^\"]+)\"", svgText))
	smilText += paths+";"
	if(i == frames):
		lastPath = paths

smilText = smilText[:-1] # Remove trailing ;
smilText += "\"\nkeyTimes=\""

for i in range(frames):
	smilText += str(i/(frames-1))+";"

smilText = smilText[:-1] # Remove trailing ;

smilText += "\"\ndur=\"" + str(frames/framerate) + """s" repeatCount="1" calcMode="discrete"/>
</defs>
<path id="frame" d=\"""" + lastPath + """"/>
</svg>"""

f = open("smil.svg", "w")
f.write(smilText)
f.close()

# print(smilText)