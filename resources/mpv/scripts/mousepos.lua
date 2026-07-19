mp.add_key_binding("F1", function()
	local mouse_pos = mp.get_property_native("mouse-pos")
	local osd_dims = mp.get_property_native("osd-dimensions")
	local video_params = mp.get_property_native("video-params")
	mp.osd_message(
		"x: "
			.. (mouse_pos.x - osd_dims.ml) * video_params.w / (osd_dims.w - osd_dims.ml - osd_dims.mr)
			.. " y: "
			.. (mouse_pos.y - osd_dims.mt) * video_params.h / (osd_dims.h - osd_dims.mt - osd_dims.mb)
	)
end)
