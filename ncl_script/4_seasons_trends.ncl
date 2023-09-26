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

    aod = new((/192,22,40/),"float")
    x = ispan(1,192,1)
    do i=0,191
        aod(i,:,:) = dim_avg_n_Wrap(a[i],0)
    end do

    
    sp = new((/48,22,40/),float)
    su = new((/48,22,40/),float)
    au = new((/48,22,40/),float)
    wi = new((/48,22,40/),float)

    n = 0
    k = 0
    do i = 0,15
        sp(k:k+2,:,:) = aod(n+3:n+5,:,:)
        su(k:k+2,:,:) = aod(n+6:n+8,:,:)
        au(k:k+2,:,:) = aod(n+9:n+11,:,:)
        wi(k:k+2,:,:) = aod(n:n+2,:,:)
        n := n+12
        k := k+3
    end do

    sp!0 = "time"
    su!0 = "time"
    au!0 = "time"
    wi!0 = "time"
    sp := sp(lat|:,lon|:,time|:)
    su := su(lat|:,lon|:,time|:)
    au := au(lat|:,lon|:,time|:)
    wi := wi(lat|:,lon|:,time|:)

    n_sp = dimsizes(sp)
    n_su = dimsizes(su)
    n_au = dimsizes(au)
    n_wi = dimsizes(wi)


    rc_sp  = regCoef(ispan(1, n_sp(2), 1),sp)
    rc_su  = regCoef(ispan(1, n_su(2), 1),su)
    rc_au  = regCoef(ispan(1, n_au(2), 1),au)
    rc_wi  = regCoef(ispan(1, n_wi(2), 1),wi)

    rc_sp@lon_name    = "regression coefficient(trend)"
    rc_sp@units    = "/day"
    rc_su@lon_name    = "regression coefficient(trend)"
    rc_su@units    = "/day"
    rc_au@lon_name    = "regression coefficient(trend)"
    rc_au@units    = "/day"
    rc_wi@lon_name    = "regression coefficient(trend)"
    rc_wi@units    = "/day"
    copy_VarCoords(sp(:,:,0),rc_sp)
    copy_VarCoords(su(:,:,0),rc_su)
    copy_VarCoords(au(:,:,0),rc_au)
    copy_VarCoords(wi(:,:,0),rc_wi)
 ;;;;;;;;;;;xian zhu xin jian yan
    df_sp = new((/22,40/),float)
    tval_sp = new((/22,40/),float)
    b_sp = new((/22,40/),float)
    df_sp = onedtond(rc_sp@nptxy-2, (/22,40/))
    tval_sp = onedtond(rc_sp@tval,(/22,40/))
    b_sp = 0.5
    prob_sp = betainc(df_sp/(df_sp+tval_sp^2), df_sp/2.0, b_sp)
    copy_VarCoords(rc_sp, prob_sp)

    df_su = new((/22,40/),float)
    tval_su = new((/22,40/),float)
    b_su = new((/22,40/),float)
    df_su = onedtond(rc_su@nptxy-2, (/22,40/))
    tval_su = onedtond(rc_su@tval,(/22,40/))
    b_su = 0.5
    prob_su = betainc(df_su/(df_su+tval_su^2), df_su/2.0, b_su)
    copy_VarCoords(rc_su, prob_su)

    df_au = new((/22,40/),float)
    tval_au = new((/22,40/),float)
    b_au = new((/22,40/),float)
    df_au = onedtond(rc_au@nptxy-2, (/22,40/))
    tval_au = onedtond(rc_au@tval,(/22,40/))
    b_au = 0.5
    prob_au = betainc(df_au/(df_au+tval_au^2), df_au/2.0, b_au)
    copy_VarCoords(rc_au, prob_au)

    df_wi = new((/22,40/),float)
    tval_wi = new((/22,40/),float)
    b_wi = new((/22,40/),float)
    df_wi = onedtond(rc_wi@nptxy-2, (/22,40/))
    tval_wi = onedtond(rc_wi@tval,(/22,40/))
    b_wi = 0.5
    prob_wi = betainc(df_wi/(df_wi+tval_wi^2), df_wi/2.0, b_wi)
    copy_VarCoords(rc_wi, prob_wi)

    wks = gsn_open_wks("pdf", "4 seasons spatial trends")
    plot = new(4,graphic)
    res                         = True
    res@gsnFrame                = False     
    res@gsnDraw                 = False 
    res@gsnAddCyclic            = False
    
    res@cnFillOn                = True
    res@cnLinesOn               = False
    res@cnFillMode              = "AreaFill"   
    res@lbOrientation           = "Vertical"

    res@sfXArray                = rc_sp&lon
    res@sfYArray                = rc_sp&lat
    res@cnLevelSelectionMode    = "ManualLevels"
    res@lbLabelStride           =1
    res@cnMinLevelValF          = -0.024   
    res@cnMaxLevelValF          = 0.024     
    res@cnLevelSpacingF         = 0.006 
    ;res@cnFillPalette           = "cmocean_balance"
    res@cnFillPalette           = "CBR_coldhot"

    res@mpMinLatF               = 23
    res@mpMaxLatF               = 45
    res@mpMinLonF               = 70
    res@mpMaxLonF               = 110
    res@lbLabelBarOn             = False
    ;res@lbLabelFontHeightF       = 0.01 
    res@gsnRightString          = ""

    res@tmXBLabelFontHeightF    = 0.025     ;set the size of x-Axis words
    res@tmYLLabelFontHeightF    = 0.025 
    res@cnInfoLabelOn            = False             ;
    res@cnLineLabelsOn           = False 
    plot(0) = gsn_csm_contour_map(wks,rc_sp, res)
    plot(1) = gsn_csm_contour_map(wks,rc_su, res)
    plot(2) = gsn_csm_contour_map(wks,rc_au, res)
    plot(3) = gsn_csm_contour_map(wks,rc_wi, res)
    ;;;;;;;;;;;;;;;;;;shape;;;;;;;;;

    shp = "/mnt/g/aerosol_data/AOD/add_TP/DBATP_Line.shp"
    shp_plot = new(4,graphic)
    tpres                       = True
    tpres@gsLineColor           = "forestgreen"
    tpres@gsLineThicknessF      =3
    do i = 0,3
        shp_plot(i) = gsn_add_shapefile_polylines(wks,plot(i),shp,tpres)
    end do   
    ;;;;;;;;;;;;;;;;;
    plot2 = new(4,graphic)
    res2 = True
    res2@gsnFrame                = False     
    res2@gsnDraw                 = False 
    res2@gsnAddCyclic            = False
    res2@cnFillOn  = True
    res2@cnLinesOn = False;
    res2@cnLineLabelsOn = False
    res2@cnInfoLabelOn = False;
    res2@lbLabelBarOn = False;
    res2@cnMonoFillPattern = False
    res2@cnLevelSelectionMode ="ExplicitLevels"
    res2@cnLevels = (/0.1/)             ; 90% 置信度          
    res2@cnFillPatterns = (/17,-1/);     ; 点的样式
    res2@cnFillColors = (/1,-1/)         ; 点的颜色 
    res2@gsnLeftString  = ""
    res2@gsnRightString = ""
    res2@cnFillDotSizeF = 0.003
    res2@cnFillOpacityF = 0.6  

    plot2(0)        = gsn_csm_contour(wks, prob_sp, res2)
    plot2(1)        = gsn_csm_contour(wks, prob_su, res2)
    plot2(2)        = gsn_csm_contour(wks, prob_au, res2)
    plot2(3)        = gsn_csm_contour(wks, prob_wi, res2)
    ;;;;;;;;;;;; 
    do i = 0,3
        overlay(plot(i), plot2(i))
    end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;panel
    panel_res                           = True
    ;panel_res@txString                  = "4 seasons spatial distribution trends"
    ;panel_res@txFontHeightF             = 0.02
    panel_res@gsnPanelLabelBar          = True
    panel_res@gsnPanelFigureStrings       = (/"(spring)","(summer)","(autumn)","(winter)"/)
    panel_res@gsnPanelFigureStringsFontHeightF = 0.015
    panel_res@amJust                    = "TopLeft"
    panel_res@lbLabelFontHeightF        =0.015 

    gsn_panel(wks,plot,(/2,2/),panel_res)
end