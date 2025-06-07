# Makefile para o módulo PAM de perguntas de segurança

# Nome base do módulo (sem extensão)
MODULE_NAME = pam_security_questions
# Arquivo fonte C
C_SOURCE = $(MODULE_NAME).c
# Arquivo objeto intermediário
OBJECT_FILE = $(MODULE_NAME).o
# Nome da biblioteca compartilhada (o módulo PAM)
SHARED_LIBRARY = $(MODULE_NAME).so
# Caminho de instalação padrão para módulos PAM (geralmente /lib64/security/ ou /lib/security/)
# Verifique qual é o caminho correto no seu sistema (e.g., com `ls /lib/security/` ou `ls /lib64/security/`)
INSTALL_PATH = /lib64/security/$(SHARED_LIBRARY) 

# Flags do compilador GCC
# -fPIC: Gera código independente de posição (essencial para bibliotecas compartilhadas).
# -fno-stack-protector: Desabilita a proteção de stack (às vezes necessário para módulos PAM).
# -Wall: Habilita todos os avisos de compilação para ajudar a identificar problemas.
# -Werror: Trata avisos como erros, forçando um código mais limpo.
CFLAGS = -fPIC -fno-stack-protector -Wall -Werror

# Flags do linker (ld)
# -x: Remove símbolos locais da tabela de símbolos da biblioteca (reduz o tamanho).
# --shared: Cria uma biblioteca compartilhada.
# -lpam: Linka contra a biblioteca PAM, que fornece as funções PAM (como pam_prompt).
LDFLAGS = -x --shared -lpam

# Regra 'all': A meta padrão que constrói a biblioteca compartilhada.
all: $(SHARED_LIBRARY)

# Regra para compilar o arquivo C em um arquivo objeto (.o).
# $<: Refere-se ao primeiro pré-requisito (pam_security_questions.c).
# $@: Refere-se ao alvo (pam_security_questions.o).
$(OBJECT_FILE): $(C_SOURCE)
	gcc $(CFLAGS) -c $< -o $@

# Regra para linkar o arquivo objeto em uma biblioteca compartilhada (.so).
$(SHARED_LIBRARY): $(OBJECT_FILE)
	ld $(LDFLAGS) -o $@ $<

# Regra 'install': Copia a biblioteca compartilhada para o diretório de módulos PAM.
# Usa 'sudo' porque o diretório de destino geralmente requer permissões de root.
install: $(SHARED_LIBRARY)
	sudo cp $(SHARED_LIBRARY) $(INSTALL_PATH)
	@echo -e "\n\n  Módulo PAM '$(SHARED_LIBRARY)' instalado em $(INSTALL_PATH)."
	@echo -e "  Agora, você precisa configurar os arquivos PAM em /etc/pam.d/ para usar este módulo."
	@echo -e "  Exemplo: Adicione a seguinte linha APÓS 'auth required pam_unix.so' em /etc/pam.d/sshd ou /etc/pam.d/common-auth:"
	@echo -e "  auth required $(INSTALL_PATH)\n"

# Regra 'uninstall': Remove a biblioteca compartilhada do diretório de módulos PAM.
uninstall:
	sudo rm -f $(INSTALL_PATH)
	@echo -e "\n\n  Módulo PAM '$(SHARED_LIBRARY)' removido de $(INSTALL_PATH)."
	@echo -e "\n\n  ATENÇÃO: Remova QUALQUER entrada relacionada a este módulo dos arquivos em /etc/pam.d/,"
	@echo -e "  caso contrário, você NÃO conseguirá fazer login.\n\n"

# Regra 'debug': Compila o arquivo C sem linkar, para fins de depuração.
# O '-E' flag pré-processa o arquivo e o '-c' compila.
debug: $(C_SOURCE)
	gcc -E $(CFLAGS) -c $< -o $(OBJECT_FILE)

# Regra 'clean': Remove os arquivos gerados pela compilação (.o e .so).
clean:
	rm -f *.o *.so

# .PHONY: Declara metas que não correspondem a arquivos físicos, para evitar conflitos.
.PHONY: all install uninstall debug clean
