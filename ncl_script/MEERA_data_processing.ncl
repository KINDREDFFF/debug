rfs = systemfunc("ls M2T*.nc4")
fs = addfiles(rfs,"r")
;;;;read variable;;;;;
U = fs[:]->U10M
V = fs[:]->V10M
lat = fs[0]->lat
lon = fs[0]->lon
time = fs[:]->time
;;;;;time message from file;;;;
MERRA_NAME = stringtochar(rfs)
year = charactertostring(MERRA_NAME(:,44:47))
month = charactertostring(MERRA_NAME(:,48:49))
year := stringtoint(year)
month := stringtoint(month)
;;;;;extract the range of Tibet plateau;;;;
U!0 = "time"
U!1 = "lat"
U!2 = "lon"
U&lat = lat
U&lon = lon
U := U(:,{23.0:45.0},{70.0:110.0})

V!0 = "time"
V!1 = "lat"
V!2 = "lon"
V&lat = lat
V&lon = lon
V := V(:,{23.0:45.0},{70.0:110.0})

lat!0 = "lat"
lat&lat = lat
lat := lat({23.0:45})

lon!0 = "lon"
lon&lon = lon
lon := lon({70.0:110.0})

year!0 = "time"
year&time = year
month!0 = "time"
month&time = month

wfile1=addfile("wind18.nc","c")
    wfile1->U10M=U
    wfile1->V10M=V
    wfile1->lat=lat
    wfile1->lon=lon
    wfile1->time=time
    wfile1->year=year
    wfile1->month=month