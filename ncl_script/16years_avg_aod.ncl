 begin 
  rfs = systemfunc("ls aod*.nc")
  fs  = addfiles(rfs,"r")
  f   = NewList("lifo")

  do i = 0,15
  	ListPush(f,fs[i]->AOD)
  end do

  aod_avg_time = NewList("lifo")
  do i = 0,15
  	ListPush(aod_avg_time,dim_avg_n_Wrap(f[i],0))
  end do

  aod_sum = 0
  do i = 0,15
  	aod_sum := aod_sum+aod_avg_time[i]  ;;;;;;;;;;;;;; 
  end do
  aod_sum_avg := aod_sum/16.0
  copy_VarMeta(aod_avg_time[0] , aod_sum_avg)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  wks    = gsn_open_wks("pdf", "MODIS_AOD_16years")
  res                            = True     ; plot mods desired

  res@gsnDraw                    = False         ; don't draw plot yet
  res@gsnFrame                   = False         ; don't advance frame yet
  res@gsnAddCyclic               = False
  res@gsnSpreadColors            = True     

  res@cnFillOn                   = True
  res@cnFillMode                 = "CellFill"  
  res@cnLinesOn                  = False
  res@cnFillPalette              = "WhiteBlueGreenYellowRed"
  res@cnMinLevelValF             = 0             ; colorbar
  res@cnMaxLevelValF             = 1.2           ; colorbar
  res@cnLevelSpacingF            = 0.15
  res@cnLevelSelectionMode       = "ManualLevels"

  res@tfDoNDCOverlay             = True
   
  res@sfXArray                   = aod_sum_avg&lon
  res@sfYArray                   = aod_sum_avg&lat

  res@lbLabelStride              = 1
  ;res@lbOrientation              = "vertical"
  res@lbLabelAutoStride          = True          ; Every other label

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

  ;res@tiMainString               = "Aerosol spatial distribution map"   ;S et title for contour

  res@tmYRMode                   = "Automatic"   ; turn off special labels on right axis 
  res@gsnLeftString=""                           ; Remove the headings
  res@gsnRightString=""
      

  plot = gsn_csm_contour_map(wks,aod_sum_avg, res)

  shp = "/mnt/g/aerosol_data/AOD/add_TP/DBATP_Line.shp"
  tpres                          = True
  tpres@gsLineColor              = "MediumBlue"
  tpres@gsLineThicknessF         = 3
  shp_plot = gsn_add_shapefile_polylines(wks,plot,shp,tpres)

  draw(plot)                                     ; This will draw attached polylines and map
  frame(wks)                                     ; Advanced frame.
end 
    



  