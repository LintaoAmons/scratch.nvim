.PHONY: test 
test:
	nvim --headless -u scripts/minimal_init.lua -c "PlenaryBustedDirectory tests { minimal_init='./scripts/minimal_init.lua', sequential=true, }"
