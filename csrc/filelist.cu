PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _748973_archive_1.so
_748973_archive_1.so : archive.8/_748973_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../out/simv.daidir//_748973_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../out/simv.daidir//_748973_archive_1.so $@


ARCHIVE_OBJS += _prev_archive_1.so
_prev_archive_1.so : archive.8/_prev_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../out/simv.daidir//_prev_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../out/simv.daidir//_prev_archive_1.so $@



VCS_ARC0 =_csrc0.so

VCS_OBJS0 =objs/amcQw_d.o 



%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<

$(VCS_ARC0) : $(VCS_OBJS0)
	$(PIC_LD) -shared  -o .//../out/simv.daidir//$(VCS_ARC0) $(VCS_OBJS0)
	rm -f $(VCS_ARC0)
	@ln -sf .//../out/simv.daidir//$(VCS_ARC0) $(VCS_ARC0)

CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \


CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(VCS_ARC0) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

