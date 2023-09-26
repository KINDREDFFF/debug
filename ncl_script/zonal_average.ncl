begin	
	rfs = systemfunc("ls aod*.nc")
	fs = addfiles(rfs,"r")
	f = NewList("fifo")
	do i = 0,15
	        ListAppend(f,fs[i]->AOD)   ;list
	end do

	aod_zonal=new((/16,22/),float)
	do i=0,15
	          aod_zonal(i,:) = dim_avg_n_Wrap(dim_avg_n_Wrap(f[i],0),1)
	end do
	    
	aod_zonal!0 = "time"
	aod_zonal := aod_zonal(lat|:,time|:)




	wks = gsn_open_wks("pdf", "ff")
	res                             = True
	res@gsnMaximize                 = True 
	res@cnFillOn                    = True
	res@cnLinesOn                   = False
	res@cnLineLabelsOn              = False  
	res@cnInfoLabelOn               = False  
	res@cnFillPalette               = "WhiteBlueGreenYellowRed"
	res@cnLevelSelectionMode        = "ManualLevels"
	;res@tiMainString                = "zonal average"
	;res@lbOrientation               = "vertical"

	res@cnMinLevelValF              = 0       ;;;;;;colorbar
	res@cnMaxLevelValF              = 0.4 
	res@cnLevelSpacingF             = 0.05 

	res@tmXBMode                         = "Explicit"
	res@tmXTLabelStride                  = 0
	res@tmXBLabelsOn                          =   True
	res@tmXBMajorLengthF                 = 0.02     ;The length of the major tick mark  
	res@tmXBMajorOutwardLengthF          = 0.02     ;The distancd of major tick mark from the x coordinate
	res@tmXBLabelDeltaF                  = 0        ; The distance of the primary scale from the label

	res@tmXBValues                       = ispan(0,15,1)       ;
	res@tmXBLabels                       = (/"2007","2008","2009","2010","2011","2012","2013",\
	                                         "2015","2016","2017","2018","2019","2020","2021","2022","2023"/)
	;res@tmXBMinorValues                  = ispan(1,15,2)    ; Manually set the secondary coordinate sca
	res@gsnLeftString=""                           ; Remove the headings
    res@gsnRightString=""
    res@tmXBLabelAngleF                  = 45

    res@tmYLMode                         = "Explicit"
    res@tmYLLabelStride                 = 0
    ;res@tmYLLabelsOn                     =True
    res@tmYLMajorLengthF                = 0.02
    res@tmYLMajorOutwardLengthF         = 0.02
    

    res@tmYLValues                       = fspan(23.5, 44.5, 11)     ; follow y coordinate values
    res@tmYLLabels                      = (/"23.5~S~o~N~N","25.5~S~o~N~N","27.5~S~o~N~N","29.5~S~o~N~N",\
                                           "31.5~S~o~N~N","33.5~S~o~N~N","35.5~S~o~N~N","37.5~S~o~N~N",\
                                           "39.5~S~o~N~N","41.5~S~o~N~N","43.5~S~o~N~N"/)
    res@tmYLMinorValues                  =fspan(24.5, 43.5, 10)
	                                        
	res@vpWidthF                    = 0.7
	res@vpHeightF                   = 0.4



	plot = gsn_csm_contour(wks, aod_zonal, res)
end