begin
;;;;;;;;;;;;;;;;;;;;aerosol data ;;;;;;;;;;;;;;;;;;   
    rfs = systemfunc("ls aod*.nc")
    fs = addfiles(rfs,"r")
    aod = fs[:]->AOD
    year = fs[:]->year
    month = fs[:]->month
    day = fs[:]->day
    ;;;;;;using month to select spring;summer;..;winter aod data 
    n = dimsizes(month)

    counts_sp = num(month(:).eq.3.or.month(:).eq.4.or.month(:).eq.5)
    counts_su = num(month(:).eq.6.or.month(:).eq.7.or.month(:).eq.8)
    counts_au = num(month(:).eq.9.or.month(:).eq.10.or.month(:).eq.11)
    counts_wi = num(month(:).eq.12.or.month(:).eq.1.or.month(:).eq.2)

    sp = new((/counts_sp,22,40/),float)
    su = new((/counts_su,22,40/),float)
    au = new((/counts_au,22,40/),float)
    wi = new((/counts_wi,22,40/),float)

    sp_n = 0
    su_n = 0
    au_n = 0
    wi_n = 0
    do i = 0,n-1
        if month(i).eq.3.or.month(i).eq.4.or.month(i).eq.5 then
            sp(sp_n,:,:) = aod(i,:,:)
            sp_n := sp_n+1
        else if month(i).eq.6.or.month(i).eq.7.or.month(i).eq.8 then
            su(su_n,:,:) = aod(i,:,:)
            su_n := su_n+1
        else if month(i).eq.9.or.month(i).eq.10.or.month(i).eq.11 then
            au(au_n,:,:) = aod(i,:,:)
            au_n := au_n+1
        else if month(i).eq.12.or.month(i).eq.1.or.month(i).eq.2 then
            wi(wi_n,:,:) = aod(i,:,:)
            wi_n := wi_n+1
        end if
        end if
        end if
        end if
    end do

    sp_avg = dim_avg_n_Wrap(sp, 0)
    su_avg = dim_avg_n_Wrap(su, 0)
    au_avg = dim_avg_n_Wrap(au, 0)
    wi_avg = dim_avg_n_Wrap(wi, 0)
;;;;;;;;;;;;;;;;;;;;;;wind data;;;;;;;;;;;;;;;;
    rfs = systemfunc("ls /mnt/g/wind/wind_field/win*.nc")
    fs = addfiles(rfs, "r")
    
    ListSetType(fs, "cat")
    U = fs[:]->U10M
    V = fs[:]->V10M
    year := fs[:]->year 
    month := fs[:]->month 

    n = dimsizes(month)

    counts_sp = num(month(:).eq.3.or.month(:).eq.4.or.month(:).eq.5)
    counts_su = num(month(:).eq.6.or.month(:).eq.7.or.month(:).eq.8)
    counts_au = num(month(:).eq.9.or.month(:).eq.10.or.month(:).eq.11)
    counts_wi = num(month(:).eq.12.or.month(:).eq.1.or.month(:).eq.2)

    sp_u = new((/counts_sp,45,65/),float)
    su_u = new((/counts_su,45,65/),float)
    au_u = new((/counts_au,45,65/),float)
    wi_u = new((/counts_wi,45,65/),float)
    sp_v = new((/counts_sp,45,65/),float)
    su_v = new((/counts_su,45,65/),float)
    au_v = new((/counts_au,45,65/),float)
    wi_v = new((/counts_wi,45,65/),float)

    sp_n = 0
    su_n = 0
    au_n = 0
    wi_n = 0
    do i = 0,n-1
        if month(i).eq.3.or.month(i).eq.4.or.month(i).eq.5 then
            sp_u(sp_n,:,:) = U(i,:,:)
            sp_v(sp_n,:,:) = V(i,:,:)
            sp_n := sp_n+1
        else if month(i).eq.6.or.month(i).eq.7.or.month(i).eq.8 then
            su_u(su_n,:,:) = U(i,:,:)
            su_v(su_n,:,:) = V(i,:,:)
            su_n := su_n+1
        else if month(i).eq.9.or.month(i).eq.10.or.month(i).eq.11 then
            au_u(au_n,:,:) = U(i,:,:)
            au_v(au_n,:,:) = V(i,:,:)
            au_n := au_n+1
        else if month(i).eq.12.or.month(i).eq.1.or.month(i).eq.2 then
            wi_u(wi_n,:,:) = U(i,:,:)
            wi_v(wi_n,:,:) = V(i,:,:)
            wi_n := wi_n+1
        end if
        end if
        end if
        end if
    end do

    sp_avg_u = dim_avg_n_Wrap(sp_u, 0)
    su_avg_u = dim_avg_n_Wrap(su_u, 0)
    au_avg_u = dim_avg_n_Wrap(au_u, 0)
    wi_avg_u = dim_avg_n_Wrap(wi_u, 0)
    sp_avg_v = dim_avg_n_Wrap(sp_v, 0)
    su_avg_v = dim_avg_n_Wrap(su_v, 0)
    au_avg_v = dim_avg_n_Wrap(au_v, 0)
    wi_avg_v = dim_avg_n_Wrap(wi_v, 0)

    wks = gsn_open_wks("pdf", "cc")
    ;;;;;;;;;;;;;;map
    map = new(4,graphic)
    res                            = True
    res@gsnDraw                    = False         ; don't draw plot yet
    res@gsnFrame                   = False         ; don't advance frame yet
    res@mpDataSetName              = "Earth..4"
    res@mpDataBaseVersion          = "MediumRes"
    res@mpOutlineOn                = True
    res@mpLandFillColor            = "white"
    res@mpNationalLineColor        = "black"
    res@mpGeophysicalLineColor     = "black" 
    res@mpMinLatF                  = 23
    res@mpMaxLatF                  = 45
    res@mpMinLonF                  = 70
    res@mpMaxLonF                  = 110
    res@mpCenterLonF               = 0             ; set map center at 180
    res@tmXBLabelFontHeightF    = 0.025     ;set the size of x-Axis words
    res@tmYLLabelFontHeightF    = 0.025    ;set the size of y-Axis words   
    res@tmYROn                     = False 
    res@tmXTOn                     = False  

    map(0) = gsn_csm_map(wks, res)   
    map(1) = gsn_csm_map(wks, res) 
    map(2) = gsn_csm_map(wks, res) 
    map(3) = gsn_csm_map(wks, res) 
    ;;;;;;;;;;;;;;;;;;;;;;;;; shape file
    shp_plot = new(4,graphic)
    shp = "/mnt/g/aerosol_data/AOD/add_TP/DBATP_Line.shp"
    tpres                          = True
    tpres@gsLineColor              = "mediumblue"
    tpres@gsLineThicknessF         = 3

    shp_plot(0) = gsn_add_shapefile_polylines(wks,map(0),shp,tpres)
    shp_plot(1) = gsn_add_shapefile_polylines(wks,map(1),shp,tpres)
    shp_plot(2) = gsn_add_shapefile_polylines(wks,map(2),shp,tpres)
    shp_plot(3) = gsn_add_shapefile_polylines(wks,map(3),shp,tpres)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;    contour
    plot = new(4,graphic)
    cnres                          = True
    cnres@gsnDraw                  = False         ; don't draw plot yet
    cnres@gsnFrame                 = False
    cnres@gsnAddCyclic             =False
    cnres@gsnSpreadColors          = True
    cnres@cnFillOn                 = True
    cnres@cnFillMode               = "CellFill"  
    cnres@cnLinesOn                = False
    cnres@cnFillPalette            = "WhiteBlueGreenYellowRed"
    cnres@cnMinLevelValF           = 0             ; colorbar
    cnres@cnMaxLevelValF           = 1.2           ; colorbar
    cnres@cnLevelSpacingF          = 0.15
    cnres@cnLevelSelectionMode     = "ManualLevels"
    cnres@tfDoNDCOverlay           = True
    cnres@lbLabelBarOn             = False    ;REMOVE colorbar
    cnres@sfXArray                 = sp&lon
    cnres@sfYArray                 = sp&lat
    cnres@lbLabelStride            = 1
    cnres@lbLabelAutoStride        = True          ; Every other label
    cnres@cnInfoLabelOn            = False             ;
    cnres@cnLineLabelsOn           = False
    cnres@tmYRMode                 = "Automatic"   ; turn off special labels on right axis 
    cnres@gsnLeftString            = ""                           ; Remove the headings
    cnres@gsnRightString           = ""

    plot(0) =  gsn_csm_contour(wks,sp_avg, cnres)
    plot(1) =  gsn_csm_contour(wks,su_avg, cnres)
    plot(2) =  gsn_csm_contour(wks,au_avg, cnres)
    plot(3) =  gsn_csm_contour(wks,wi_avg, cnres)
    overlay(map(0), plot(0))
    overlay(map(1), plot(1))
    overlay(map(2), plot(2))
    overlay(map(3), plot(3))
   
    ;;;;;;;;;;;;;;;;;;;;;;;;add vector
    vector = new(4,graphic)
    vcres                          = True
    vcres@gsnDraw                  = False         ; don't draw plot yet
    vcres@gsnFrame                 = False
    vcres@gsnAddCyclic             =False
    vcres@gsnSpreadColors          = True

    vcres@vcRefAnnoOrthogonalPosF  = -1.0             ; move ref vector up
    vcres@vcRefMagnitudeF          = 4.0             ; define vector ref mag
    vcres@vcRefLengthF             = 0.090            ; define length of vec ref
    vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF           = 0.017
    vcres@vcRefAnnoFontHeightF     = 0.015
    vcres@gsnLeftStringFontHeightF =0.035
    vcres@gsnRightStringFontHeightF=0.035
    vcres@gsnLeftString            ="10-meter-wind" 
    vector(0) = gsn_csm_vector(wks,sp_avg_u,sp_avg_v,vcres)
    vector(1) = gsn_csm_vector(wks,su_avg_u,su_avg_v,vcres)
    vector(2) = gsn_csm_vector(wks,au_avg_u,au_avg_v,vcres)
    vector(3) = gsn_csm_vector(wks,wi_avg_u,wi_avg_v,vcres)
    overlay(map(0),vector(0))
    overlay(map(1),vector(1))
    overlay(map(2),vector(2))
    overlay(map(3),vector(3))
    ;;;;;;;;;;;;;;;;panel draw;;;;;;;;;;;
    panel_res                           = True
    ;panel_res@txString                  = "4 seasons spatial distribution"
    ;panel_res@txFontHeightF             = 0.015
    panel_res@gsnPanelLabelBar          = True
    panel_res@gsnPanelFigureStrings       = (/"(spring)","(summer)","(autumn)","(winter)"/)
    panel_res@gsnPanelFigureStringsFontHeightF = 0.015
    panel_res@amJust                    = "TopLeft"

    gsn_panel(wks,map,(/2,2/),panel_res)
    ;draw(map(0))
    ;draw(map(1))
    ;draw(map(2))
    ;draw(map(3))
    
  
    
end