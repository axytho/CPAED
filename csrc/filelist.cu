PIC_LD=ld

ARCHIVE_OBJS=
<<<<<<< HEAD
ARCHIVE_OBJS += _740160_archive_1.so
_740160_archive_1.so : archive.7/_740160_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../out/simv.daidir//_740160_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../out/simv.daidir//_740160_archive_1.so $@


ARCHIVE_OBJS += _prev_archive_1.so
_prev_archive_1.so : archive.7/_prev_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../out/simv.daidir//_prev_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../out/simv.daidir//_prev_archive_1.so $@
=======
ARCHIVE_OBJS += _1799850_archive_1.so
_1799850_archive_1.so : archive.24/_1799850_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../out/simv.daidir//_1799850_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../out/simv.daidir//_1799850_archive_1.so $@
>>>>>>> 014fa35fe15b99fad279a8a0c89b69d4b422fedd






%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

