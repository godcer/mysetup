-- ==================================================
-- MOUSE: click-to-open (minimal)
--   Left click  -> open (dir: enter | file: nvim / system default)
--   Right click -> "Open With" menu
-- ==================================================
function Entity:click(event, up)
	if up or event.is_middle then
		return
	end

	ya.emit("reveal", { self._file.url })
	ya.emit("open", { interactive = event.is_right })
end
