all:
	ml-build sources.cm Main.main tigcc

clean:
	find . -type d -name .cm -exec rm -r {} +
	rm -f FrontEnd/tiger.{lex,grm}.{desc,sig,sml}
	rm -f tigcc.$(shell sml @SMLsuffix)
