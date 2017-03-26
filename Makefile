slides:
	pandoc Readme.md \
	--to revealjs \
	--template template/index.html \
	--output index.html \
	-V revealjs-url=template \
	-V theme=solarized \
	-V progress=true \
	-V slideNumber=true \
	-V history=true \
	--standalone --slide-level 2
