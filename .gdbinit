set debuginfod enabled on
source /usr/share/pwndbg/gdbinit.py
source /home/daniele/.config/splitmind/gdbinit.py 
python
import splitmind
(splitmind.Mind()
  .tell_splitter(show_titles=True)
  .tell_splitter(set_title="Main")
  .right(display="backtrace", size="25%")
  .below(display="legend", size="80%").show("regs", on="legend")
  .above(of="main", display="disasm", size="70%", banner="top")
  .show("code", on="disasm", banner="none")
  .above(display="stack", size="50%")
  #.right(cmd='/bin/bash', of="main", size="30%", clearing=False)
  #.tell_splitter(set_title='cmd')
).build(nobanner=True)
end
