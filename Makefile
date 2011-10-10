SUFFICES = .cc .so .ui .qrc .rb

CXX = g++
RUBY = ruby
RBUIC = rbuic4
RBRCC = rbrcc

RUBYINC = $(shell $(RUBY) -e "require 'mkmf'; puts Config::CONFIG.member?('rubyhdrdir') ? \"-I\#{Config::CONFIG['rubyhdrdir']} -I\#{Config::CONFIG['rubyhdrdir']}/\#{Config::CONFIG['arch']}\" : \"-I\#{Config::CONFIG['archdir']}\"")

all: ui_mainwindow.rb qrc_whiteboard.rb x11test.so

x11test.so: x11test.o
	$(CXX) -shared -o $@ x11test.o -lXtst

dist:
	tar cjf whiteboard.tar.bz2 Makefile *.rb *.png *.ui *.qrc *.cc

clean:
	rm -f *.so *.o ui_*.rb qrc_*.rb

qrc_whiteboard.rb: whiteboard.qrc exit.png configure.png connect.png disconnect.png \
    whiteboard.png
x11test.o: x11test.cc
x11test.so: x11test.o

ui_%.rb: %.ui
	$(RBUIC) $< > $@

qrc_%.rb: %.qrc
	$(RBRCC) $< > $@

.cc.o:
	$(CXX) -c $< -o $@ -fPIC -O -DNDEBUG $(RUBYINC)

-include $(wildcard .deps/*.P) :-)

