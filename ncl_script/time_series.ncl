begin
    rfs = systemfunc("ls aod*.nc")
    fs  = addfiles(rfs,"r")
    ;              read AOD           ;
    f = NewList("fifo")
    do i = 0,15
    ListAppend(f,fs[i]->AOD)          ;list
    end do
    ;;;;;;;;;;;;;;;;;;;;;
    m = NewList("fifo")

    do i = 0,15
     ListAppend(m,fs[i]->month)       ;list
    end do
    ;;;;;;;;;;;;;;;
    y = NewList("fifo")

    do i = 0,15
     ListAppend(y,fs[i]->year)        ;list
    end do
    ;            Extract data from each month of the year and store it in a list  ;

    a = NewList("lifo")
    do i =0,15
    counts = new(12,"integer")
    n = 0
    do j = 0,11
        counts(j)=num(m[i](:).eq.(j+1))
        ListAppend(a,f[i](n:(n+counts(j)-1),:,:))
        n := n+counts(j)     
    end do
    delete(counts)
    delete(n)
    end do

    aod = new(192,"float")
    x = ispan(0,191,1)
    do i=0,191
        aod(i) = avg(dim_avg_n_Wrap(dim_avg_n_Wrap(a[i],2),1))
    end do
    k = regline(x,aod)
    b = avg(aod)-k*avg(x)
    y_ = k*x+b

    aod_m = new(12,float)
    do i = 0,11
        aod_m(i) = avg(aod(i:191:12))
    end do
    x_m = ispan(0,11,1)


    wks = gsn_open_wks("pdf","time_series")
    plot = new(2,graphic)
    resR                                  = True
    resR@gsnDraw                          = False         ; don't draw plot yet
    resR@gsnFrame                         = False   
    ;resR@tiMainString                     = "Time series and trend lines"
    resR@trYMaxF                          = 0.60
    resR@trYMinF                          = 0.10
    resR@tmYROn                           = False     ; turn off Right scale
    resR@xyLineThicknessF                 =2.5
    resR@xyLineColor                      = "Red"

    resL                                  = True
    resL@gsnDraw                          = False         ; don't draw plot yet
    resL@gsnFrame                         = False   
    resL@trYMaxF                          = 0.60
    resL@trYMinF                          = 0.10
    resL@tiXAxisString = "year"               ;set x title
    resL@tiYAxisString = "Aerosol Optical Depth "
    resL@tmXTOn                           = False     ; turn off top scale

    

    resL@tmXBMode                         = "Explicit"
    resL@tmXTLabelStride                  = 0
    resL@tmXBLabelsOn                          =   True
    resL@tmXBMajorLengthF                 = 0.02     ;The length of the major tick mark  
    resL@tmXBMajorOutwardLengthF          = 0.02     ;The distancd of major tick mark from the x coordinate
    resL@tmXBLabelDeltaF                  = 0        ; The distance of the primary scale from the label
    ;resL@tmXBValues                      = ispan(0,203,12)
    ;resL@tmXBLabels                      = (/"2007"," ","2009"," ","2011"," ","2013",\
    ;                                         " ","2015"," ","2017"," ","2019"," ","2021"," ","2023"/)
    resL@tmXBValues                       = ispan(0,192,24)
    resL@tmXBLabels                       = (/"2007","2009","2011","2013",\
                                             "2015","2017","2019","2021","2023"/)
    resL@tmXBMinorValues                  = ispan(12,192,12)    ; Manually set the secondary coordinate scale

    ;resL@tmXBMinorPerMajor               = 4          ;Specifies the number of minor tick marks


    ;resL@tmXBMode                        = "Manual"
    ;resL@tmXBTickStartF                  = 2007
    ;resL@tmXBTickEndF                    = 2023
    ;resL@tmXBTickSpacingF                = 2
    
    resL@tmXBLabelAngleF                  = -45.0
    resL@vpHeightF                         = 0.5
    resL@vpWidthF                          = 0.7

    resL@xyLineThicknessF                  =2.5
    resL@xyLineColor                       ="Blue"
    resL@xyDashPattern                     = 3    
    resL@tmXTBorderOn                      = False
    resL@tmYRBorderOn                      = False  
    

    plot(0)                                  = gsn_csm_xy2(wks,x,aod,y_,resL,resR)
    txres               = True                     ; text mods desired
    txres@txFontHeightF = 0.030                     ; font smaller. default big

    dum = gsn_add_text(wks,plot(0),"y= -0.00016x+0.35",90,0.575,txres) 

    resb                                  = True
    resb@gsnDraw                          = False         ; don't draw plot yet
    resb@gsnFrame                         = False 
    resb@gsnXYBarChart                    = True
    resb@gsnXYBarChartBarWidth            = 0.25
    resb@gsnYRefLine                      = 0.10
    ;resb@gsnAboveYRefLineColor            = "grey10"
    resb@gsnXYBarChartColors              = "DeepSkyBlue"
 
    resb@tmXBMode                         = "Explicit"
    resb@tmXTLabelStride                  = 0
    resb@tmXBLabelsOn                          =   True
    resb@tmXBMajorLengthF                 = 0.02     ;The length of the major tick mark  
    resb@tmXBMajorOutwardLengthF          = 0.02     ;The distancd of major tick mark from the x coordinate
    resb@tmXBLabelDeltaF                  = 0        ; The distance of the primary scale from the label
 
    resb@tmXBValues                       = ispan(0,11,1)
    resb@tmXBLabels                       = (/"1","2","3","4","5","6","7",\
                                             "8","9","10","11","12"/)
    

    
    ;resb@tmXBLabelAngleF                  = -45.0
    resb@vpHeightF                         = 0.5
    resb@vpWidthF                          = 0.7
    resb@tiXAxisString = "month"               ;set x title
    resb@tiYAxisString = "Aerosol Optical Depth "
    resb@tmXTOn                            = False
    resb@tmYROn                            = False 
    ;resb@tmXTBorderOn                      = False
    ;resb@tmYRBorderOn                      = False
    resb@gsnXYBarChartBarWidth              = 0.4

    plot(1) = gsn_csm_xy(wks,x_m,aod_m,resb)
    
    panel_res                           = True
    ;panel_res@txString                  = "4 seasons spatial distribution trends"
    ;panel_res@txFontHeightF             = 0.02
    ;panel_res@gsnPanelLabelBar          = True
    panel_res@gsnPanelFigureStrings       = (/"(a)","(b)"/)
    panel_res@gsnPanelFigureStringsFontHeightF = 0.015
    panel_res@amJust                    = "TopLeft"

    gsn_panel(wks,plot,(/2,1/),panel_res)

    frame(wks)
end