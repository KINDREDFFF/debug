rfs = systemfunc("ls  /mnt/e/aerosol_data/2010/MYD08_D3.A*")
fs = addfiles(rfs,"r")

ListSetType(fs,"join")
aod = fs[:]->AOD_550_Dark_Target_Deep_Blue_Combined_Mean
aod@lat = fs[0]->YDim
aod@lon = fs[0]->XDim
aod!0 = "time"
aod!1 = "lat"
aod!2 = "lon"
aod&lat = aod@lat
aod&lon = aod@lon


latMin = 25.0
latMax = 45.0
lonMin = 75.0
lonMax = 105.0

aod := short2flt(aod(:,{23.0:45.0},{70.0:110.0}))

;;;;;;;;;;;;;;;;;;;read year,month,day;;;;;;;;;;;;;;;
modfiles = systemfunc("ls MYD*")
modname = stringtocharacter(modfiles)
moddate = stringtointeger(charactertostring(modname(:,10:16)))
s = dimsizes(moddate)
moddate_ = new(s,string)
do i = 0,s-1
	moddate_(i) = yyyyddd_to_yyyymmdd(moddate(i)) 
end do

moddate_cha = stringtocharacter(moddate_)
year = new(s,string)
month = new(s,string)
day = new(s,string)
do i = 0,s-1
	year(i) = charactertostring(moddate_cha(i,0:3))
	month(i) = charactertostring(moddate_cha(i,4:5))
      day(i) = charactertostring(moddate_cha(i,6:7))
end do

year:=tointeger(year)
month:=tointeger(month)
day:=tointeger(day)

year!0="time"
month!0="time"
day!0="time"


wfile1=addfile("/mnt/e/aerosol_data/2010/aod10.nc","c")
      wfile1->AOD=aod
 	wfile1->year=year
	wfile1->month=month
      wfile1->day=day