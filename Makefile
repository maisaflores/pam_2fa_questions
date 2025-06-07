pam_security_questions.o: pam_security_questions.c
	gcc -fPIC -fno-stack-protector -c pam_security_questions.c

install: pam_security_questions.o
	ld -x --shared -o /lib64/security/pam_security_questions.so pam_security_questions.o

uninstall:
	rm -f /lib64/security/pam_security_questions.so
	@echo -e "\n\n      Remove any entry related to this module in /etc/pam.d/ files,\n      otherwise you're not going to be able to login.\n\n"
debug:
	gcc -E -fPIC -fno-stack-protector -c pam_security_questions.c
clean:
	rm -rf *.o
