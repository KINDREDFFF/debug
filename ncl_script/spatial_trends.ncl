begin
    rfs = systemfunc("ls aod*.nc")
    fs = addfiles(rfs, "r")

    f = NewList("lifo")
    do i = 0,15
        ListAppend(f, fs[i]->AOD)
    end do

    f_t_avg = NewList("lifo")
    do i = 0,15
        ListAppend(f_t_avg,dim_avg_n_Wrap(f[i],0))
    end do

    list_to_array = new((/16,22,40/), float)
    do i =0,15
        do j =0,21
            do k=0,39   
                list_to_array(i,j,k) = f_t_avg[i](j,k)
            end do
        end do
    end do

    list_to_array!0 = "time"
    list_to_array!1 = "lat"
    list_to_array!2 = "lon"
    list_to_array := list_to_array(lat|:,lon|:,time|:)
    copy_VarAtts(f_t_avg[0], list_to_array)
    list_to_array&lat = f_t_avg[0]&lat
    list_to_array&lon = f_t_avg[0]&lon
    list_to_array&time = ispan(1,16,1)

    time = list_to_array&time
    rc             = regCoef(time,list_to_array)
    rc@lon_name    = "regression coefficient(trend)"
    rc@units    = "/day"
    copy_VarCoords(list_to_array(:,:,0),rc)
    t = rc*sqrt((16-2)/(1-rc^2))
    df = new((/22,40/),float)
    tval = new((/22,40/),float)
    b = new((/22,40/),float)
    df = onedtond(rc@nptxy-2, (/22,40/))
    tval = onedtond(rc@tval,(/22,40/))
    b = 0.5
    prob = betainc(df/(df+tval^2), df/2.0, b)*0.5
    copy_VarCoords(rc, prob)

    wks = gsn_open_wks("pdf", "spatial_trends")
    res                         = True
    res@gsnFrame                = False     
    res@gsnDraw                 = False 
    res@gsnAddCyclic            = False
    
    res@cnFillOn                = True
    res@cnLinesOn               = False
    res@cnFillMode              = "AreaFill"   
    ;res@lbOrientation           = "Vertical"

    res@sfXArray                = rc&lon
    res@sfYArray                = rc&lat
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

    res@gsnRightString          = ""
    ;res@tiMainString            = "spatial_trends"
    plot = gsn_csm_contour_map(wks,rc, res)


    shp = "/mnt/g/aerosol_data/AOD/add_TP/DBATP_Line.shp"
    tpres                       = True
    tpres@gsLineColor           = "forestgreen"
    tpres@gsLineThicknessF      =3
    shp_plot = gsn_add_shapefile_polylines(wks,plot,shp,tpres)
  

    ;;;;;;;;;;;;;;;;;
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
    ;;;;;;;;;;;; 

    plot2        = gsn_csm_contour(wks, prob, res2)




    overlay(plot,plot2)  
    draw(plot)
    frame(wks)
  
end
