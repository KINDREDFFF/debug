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
    x = ispan(1,192,1)
    do i=0,191
        aod(i) = avg(dim_avg_n_Wrap(dim_avg_n_Wrap(a[i],2),1))
    end do

    sp = new(48,float)
    su = new(48,float)
    au = new(48,float)
    wi = new(48,float)

    n = 0
    k = 0
    do i = 0,15
        sp(k:k+2) = aod(n+3:n+5)
        su(k:k+2) = aod(n+6:n+8)
        au(k:k+2) = aod(n+9:n+11)
        wi(k:k+2) = aod(n:n+2)
        n := n+12
        k := k+3
    end do
    
    x := ispan(1,48,1)
    k_sp = regline(x,sp)
    k_su = regline(x,su)
    k_au = regline(x,au)
    k_wi = regline(x,wi)
    b_sp = avg(sp)-k_sp*avg(x)
    b_su = avg(su)-k_su*avg(x)
    b_au = avg(au)-k_au*avg(x)
    b_wi = avg(wi)-k_wi*avg(x)
    y_sp = k_sp*x+b_sp
    y_su = k_su*x+b_su
    y_au = k_au*x+b_au
    y_wi = k_wi*x+b_wi

    wks = gsn_open_wks("pdf","4 seasons time series")
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
    ;resL@tiXAxisString = "year"               ;set x title
    ;resL@tiYAxisString = "Aerosol concentration"
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
    resL@tmXBValues                       = ispan(0,48,6)
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
    resL@vpWidthF                          = 0.8
    resL@xyLineThicknessF                  =2.5
    resL@xyLineColor                       ="Blue"
    resL@xyDashPattern                     = 3   
    
    plot = new(4,graphic)
    plot(0)                                  = gsn_csm_xy2(wks,x,sp,y_sp,resL,resR)
    plot(1)                                  = gsn_csm_xy2(wks,x,su,y_su,resL,resR)
    plot(2)                                  = gsn_csm_xy2(wks,x,au,y_au,resL,resR)
    plot(3)                                  = gsn_csm_xy2(wks,x,wi,y_wi,resL,resR)
    ;;;;;;;;;;;;;;;;;;;;;;text;;;;;;;;;;;
    dum = new(4,graphic)
    txres               = True                     ; text mods desired
    txres@txFontHeightF = 0.030                     ; font smaller. default big

    dum(0) = gsn_add_text(wks,plot(0),"y= -0.00109x+0.46",37,0.57,txres)
    dum(1) = gsn_add_text(wks,plot(1),"y= -0.00145x+0.39",37,0.57,txres) 
    dum(2) = gsn_add_text(wks,plot(2),"y= 0.00026x+0.23",37,0.57,txres) 
    dum(3) = gsn_add_text(wks,plot(3),"y= 0.00035x+0.32",37,0.57,txres)  

    panel_res                           = True
    ;panel_res@txString                  = "4 seasons time series"
    panel_res@txFontHeightF             = 0.02
    panel_res@gsnPanelFigureStrings       = (/"(spring)","(summer)","(autumn)","(winter)"/)
    panel_res@gsnPanelFigureStringsFontHeightF = 0.015
    panel_res@amJust                    = "TopLeft"

    gsn_panel(wks,plot,(/2,2/),panel_res)

    
end
