create function distance(
	x1 int(11), 
	y1 int(11),
	x2 int(11),
	y2 int(11))
returns float
return sqrt( pow(( x1 - x2)*0.007692, 2) + pow((y1-y2) * 0.007692, 2) )